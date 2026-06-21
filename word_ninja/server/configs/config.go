package config

import (
	"fmt"
	"os"
	"strings"
)

type Config struct {
	Port          string
	DatabaseURL   string
	RedisURL      string
	JWTSecret     string
	OpenAIKey     string
	OpenAIBaseURL string
	RateLimitRPM  int
}

func Load() *Config {
	jwtSecret := getEnv("JWT_SECRET", "word-ninja-secret-change-in-production")
	// 生产环境检查：如果使用默认密钥且不在开发模式，发出警告
	if jwtSecret == "word-ninja-secret-change-in-production" &&
		!strings.HasPrefix(getEnv("DATABASE_URL", ""), "postgres://postgres:postgres@localhost") {
		fmt.Fprintln(os.Stderr, "WARNING: Using default JWT_SECRET. Set JWT_SECRET environment variable in production!")
	}

	return &Config{
		Port:          getEnv("PORT", "8080"),
		DatabaseURL:   getEnv("DATABASE_URL", "postgres://postgres:postgres@localhost:5432/word_ninja?sslmode=disable"),
		RedisURL:      getEnv("REDIS_URL", "redis://localhost:6379/0"),
		JWTSecret:     jwtSecret,
		OpenAIKey:     getEnv("OPENAI_API_KEY", ""),
		OpenAIBaseURL: getEnv("OPENAI_BASE_URL", "https://api.openai.com/v1"),
		RateLimitRPM:  60,
	}
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
