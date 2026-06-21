package vocabulary

import (
	"time"

	"gorm.io/gorm"
)

// Word 单词模型
type Word struct {
	ID        string    `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	UserID    string    `gorm:"not null;index" json:"user_id"`
	Word      string    `gorm:"not null;size:255" json:"word"`
	Meaning   string    `gorm:"size:500" json:"meaning"`
	Phonetic  string    `gorm:"size:255" json:"phonetic"`
	Example   string    `gorm:"size:1000" json:"example"`
	Difficulty int     `gorm:"default:1" json:"difficulty"`
	Mastery   int       `gorm:"default:0" json:"mastery"`
	Source    string    `gorm:"size:50" json:"source"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// Review 复习记录
type Review struct {
	ID         string    `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	WordID     string    `gorm:"not null;index" json:"word_id"`
	UserID     string    `gorm:"not null;index" json:"user_id"`
	ReviewTime time.Time `gorm:"not null" json:"review_time"`
	Score      int       `gorm:"not null" json:"score"` // 1-5
	CreatedAt  time.Time `json:"created_at"`
}

// CreateWordRequest 创建单词请求
type CreateWordRequest struct {
	Word       string `json:"word" binding:"required"`
	Meaning    string `json:"meaning"`
	Phonetic   string `json:"phonetic"`
	Example    string `json:"example"`
	Difficulty int    `json:"difficulty"`
	Source     string `json:"source"`
}

// CreateReviewRequest 创建复习记录请求
type CreateReviewRequest struct {
	WordID string `json:"word_id" binding:"required"`
	Score  int    `json:"score" binding:"required,min=1,max=5"`
}

// PaginatedResponse 分页响应
type PaginatedResponse struct {
	Data  interface{} `json:"data"`
	Total int64       `json:"total"`
	Page  int         `json:"page"`
	Size  int         `json:"size"`
}

// ListWords 分页获取单词列表
func ListWords(db *gorm.DB, userID string, page, size int) (*PaginatedResponse, error) {
	var words []Word
	var total int64
	offset := (page - 1) * size
	db.Model(&Word{}).Where("user_id = ?", userID).Count(&total)
	if err := db.Where("user_id = ?", userID).Order("created_at DESC").Offset(offset).Limit(size).Find(&words).Error; err != nil {
		return nil, err
	}
	return &PaginatedResponse{
		Data:  words,
		Total: total,
		Page:  page,
		Size:  size,
	}, nil
}

// CreateWord 创建单词
func CreateWord(db *gorm.DB, userID string, req CreateWordRequest) (*Word, error) {
	word := Word{
		UserID:     userID,
		Word:       req.Word,
		Meaning:    req.Meaning,
		Phonetic:   req.Phonetic,
		Example:    req.Example,
		Difficulty: req.Difficulty,
		Source:     req.Source,
		Mastery:    0,
	}
	if err := db.Create(&word).Error; err != nil {
		return nil, err
	}
	return &word, nil
}

// CreateReview 创建复习记录
func CreateReview(db *gorm.DB, userID string, req CreateReviewRequest) (*Review, error) {
	review := Review{
		WordID:     req.WordID,
		UserID:     userID,
		ReviewTime: time.Now(),
		Score:      req.Score,
	}
	if err := db.Create(&review).Error; err != nil {
		return nil, err
	}
	// 更新单词掌握度
	db.Model(&Word{}).Where("id = ? AND user_id = ?", req.WordID, userID).
		UpdateColumn("mastery", gorm.Expr("LEAST(100, mastery + ?)", req.Score*5))
	return &review, nil
}

// GetDueReviews 获取到期复习的单词
func GetDueReviews(db *gorm.DB, userID string) ([]Word, error) {
	var words []Word
	// 简单策略：掌握度 < 80 且 24小时内未复习的单词
	subQuery := db.Model(&Review{}).
		Select("word_id").
		Where("user_id = ? AND review_time > ?", userID, time.Now().Add(-24*time.Hour)).
		Group("word_id")
	if err := db.Where("user_id = ? AND mastery < 80 AND id NOT IN (?)", userID, subQuery).
		Order("mastery ASC").Limit(20).Find(&words).Error; err != nil {
		return nil, err
	}
	return words, nil
}
