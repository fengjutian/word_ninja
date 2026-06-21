package database

import (
	"log/slog"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	gormlogger "gorm.io/gorm/logger"
)

var DB *gorm.DB

func Connect(databaseURL string) (*gorm.DB, error) {
	db, err := gorm.Open(postgres.Open(databaseURL), &gorm.Config{
		Logger: gormlogger.Default.LogMode(gormlogger.Warn),
	})
	if err != nil {
		return nil, err
	}
	slog.Info("database connected")
	DB = db
	return db, nil
}

func AutoMigrate(db *gorm.DB, models ...interface{}) error {
	if err := db.AutoMigrate(models...); err != nil {
		return err
	}
	slog.Info("database migrated")
	return nil
}

// Close 关闭数据库连接池
func Close(db *gorm.DB) {
	if db == nil {
		return
	}
	sqlDB, err := db.DB()
	if err != nil {
		slog.Warn("get underlying sql.DB failed", "error", err)
		return
	}
	if err := sqlDB.Close(); err != nil {
		slog.Warn("close database failed", "error", err)
		return
	}
	slog.Info("database closed")
}
