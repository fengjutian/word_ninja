package main

import (
	"context"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/word-ninja/server/configs"
	"github.com/word-ninja/server/internal/ai"
	"github.com/word-ninja/server/internal/auth"
	"github.com/word-ninja/server/internal/sync"
	"github.com/word-ninja/server/internal/vocabulary"
	"github.com/word-ninja/server/pkg/database"
	"github.com/word-ninja/server/pkg/jwt"
	"github.com/word-ninja/server/pkg/logger"
	"github.com/word-ninja/server/pkg/middleware"
	"github.com/word-ninja/server/pkg/redis"
)

func main() {
	cfg := configs.Load()
	logger.Init("development")

	// ─── 数据库 ───
	db, err := database.Connect(cfg.DatabaseURL)
	if err != nil {
		slog.Error("database connect failed, running without DB", "error", err)
	} else {
		if err := database.AutoMigrate(db,
			&auth.User{},
			&vocabulary.Word{},
			&vocabulary.Review{},
		); err != nil {
			slog.Error("auto-migrate failed", "error", err)
		}
	}

	// ─── Redis ───
	_, err = redis.Connect(cfg.RedisURL)
	if err != nil {
		slog.Warn("redis connect failed, running without cache", "error", err)
	}

	// ─── Handlers ───
	authHandler := &auth.Handler{DB: db, JWTSecret: cfg.JWTSecret}
	vocabHandler := &vocabulary.Handler{DB: db}
	aiHandler := &ai.Handler{
		APIKey:     cfg.OpenAIKey,
		BaseURL:    cfg.OpenAIBaseURL,
		HTTPClient: &http.Client{Timeout: 90 * time.Second},
	}
	syncHandler := &sync.Handler{DB: db}

	// ─── 路由 ───
	r := gin.Default()
	r.Use(middleware.CORS())

	api := r.Group("/api/v1")
	{
		// Auth（无需认证）
		authGroup := api.Group("/auth")
		{
			authGroup.POST("/register", authHandler.Register)
			authGroup.POST("/login", authHandler.Login)
		}

		// 需要认证的路由
		authorized := api.Group("")
		authorized.Use(middleware.AuthRequired(cfg.JWTSecret))
		{
			// 用户
			authorized.GET("/auth/me", authHandler.Me)

			// 单词
			authorized.GET("/words", vocabHandler.List)
			authorized.POST("/words", vocabHandler.Create)
			authorized.POST("/words/reviews", vocabHandler.Review)
			authorized.GET("/words/reviews/due", vocabHandler.DueReviews)

			// AI
			authorized.POST("/ai/chat", aiHandler.Chat)

			// 同步
			authorized.POST("/sync", syncHandler.Sync)
		}
	}

	// 健康检查
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "service": "word-ninja"})
	})

	// ─── 启动服务器 ───
	srv := &http.Server{
		Addr:    ":" + cfg.Port,
		Handler: r,
	}

	go func() {
		slog.Info("Word Ninja API starting", "port", cfg.Port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			slog.Error("server failed", "error", err)
			os.Exit(1)
		}
	}()

	// 优雅关闭
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	slog.Info("shutting down...")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		slog.Error("forced shutdown", "error", err)
	}
	slog.Info("server stopped")
}

// 示例 JWT 工具（用于外部生成测试 token）
func generateTestToken(secret string) {
	token, _, _ := jwt.GenerateToken(secret, "test-user-id", "test@example.com")
	println("Test token:", token)
}
