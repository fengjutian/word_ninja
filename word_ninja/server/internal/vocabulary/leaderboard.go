package vocabulary

import "gorm.io/gorm"

// LeaderboardEntry 排行榜条目
type LeaderboardEntry struct {
	Rank         int    `json:"rank"`
	UserID       string `json:"user_id"`
	Nickname     string `json:"nickname"`
	TotalWords   int64  `json:"total_words"`
	TotalReviews int64  `json:"total_reviews"`
	Mastered     int64  `json:"mastered"`
}

// GetLeaderboard 按词汇量排行
func GetLeaderboard(db *gorm.DB, limit int) ([]LeaderboardEntry, error) {
	if limit <= 0 || limit > 100 {
		limit = 20
	}

	rows, err := db.Raw(`
		SELECT
			ROW_NUMBER() OVER (ORDER BY COUNT(w.id) DESC, MAX(w.mastery) DESC) AS rank,
			w.user_id,
			'' AS nickname,
			COUNT(w.id) AS total_words,
			COALESCE(SUM(r.review_count), 0) AS total_reviews,
			COUNT(CASE WHEN w.mastery >= 80 THEN 1 END) AS mastered
		FROM words w
		LEFT JOIN (
			SELECT word_id, COUNT(*) AS review_count
			FROM reviews
			GROUP BY word_id
		) r ON r.word_id = w.id
		GROUP BY w.user_id
		ORDER BY total_words DESC, mastered DESC
		LIMIT ?
	`, limit).Rows()
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var entries []LeaderboardEntry
	for rows.Next() {
		var e LeaderboardEntry
		if err := db.ScanRows(rows, &e); err != nil {
			return nil, err
		}
		entries = append(entries, e)
	}
	return entries, nil
}
