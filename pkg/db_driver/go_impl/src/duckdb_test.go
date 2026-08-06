package main

import (
	"testing"
	"time"
)

func TestOpenDuckdbMemoryQuery(t *testing.T) {
	conn, err := openDuckdbConn(":memory:")
	if err != nil {
		t.Fatalf("open: %v", err)
	}
	defer conn.Close()

	cur, err := conn.OpenQuery("SELECT 42 AS n, 'duck' AS s")
	if err != nil {
		t.Fatalf("open query: %v", err)
	}
	defer cur.Close()

	h := cur.Header()
	if len(h.columns) != 2 {
		t.Fatalf("expected 2 columns, got %d", len(h.columns))
	}

	row, ok, err := cur.NextRow()
	if err != nil || !ok {
		t.Fatalf("next row: ok=%v err=%v", ok, err)
	}
	if len(row.values) != 2 {
		t.Fatalf("expected 2 values, got %d", len(row.values))
	}
	_, ok, err = cur.NextRow()
	if err != nil || ok {
		t.Fatalf("expected EOF, ok=%v err=%v", ok, err)
	}
}

func TestDuckdbKillQuery(t *testing.T) {
	conn, err := openDuckdbConn(":memory:")
	if err != nil {
		t.Fatalf("open: %v", err)
	}
	defer conn.Close()

	started := make(chan struct{})
	done := make(chan error, 1)
	go func() {
		close(started)
		// 笛卡尔积足够慢，便于 KillQuery 打断。
		cur, err := conn.OpenQuery(`
SELECT count(*) FROM range(200000000) AS a, range(100) AS b
`)
		if err != nil {
			done <- err
			return
		}
		defer cur.Close()
		for {
			_, ok, err := cur.NextRow()
			if err != nil {
				done <- err
				return
			}
			if !ok {
				done <- nil
				return
			}
		}
	}()

	<-started
	time.Sleep(50 * time.Millisecond)
	if err := conn.KillQuery(); err != nil {
		t.Fatalf("kill: %v", err)
	}

	select {
	case err := <-done:
		if err == nil {
			t.Fatalf("expected cancel error, query finished")
		}
		if !streamErrIsCancel(err) && !isDuckdbInterrupt(err) {
			t.Fatalf("unexpected kill err=%v (type=%T)", err, err)
		}
	case <-time.After(30 * time.Second):
		t.Fatalf("kill did not stop query in time")
	}
}
