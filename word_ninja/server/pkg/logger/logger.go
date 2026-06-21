package logger

import (
	"io"
	"log/slog"
	"os"
)

var Log *slog.Logger

func Init(env string) {
	var handler slog.Handler
	opts := &slog.HandlerOptions{
		Level: slog.LevelInfo,
	}
	if env == "development" {
		handler = slog.NewTextHandler(os.Stdout, opts)
	} else {
		handler = slog.NewJSONHandler(os.Stdout, opts)
	}
	Log = slog.New(handler)
	slog.SetDefault(Log)
}

// Discard logger for tests
func Discard() {
	Log = slog.New(slog.NewTextHandler(io.Discard, nil))
	slog.SetDefault(Log)
}
