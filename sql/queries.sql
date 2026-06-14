1. Calculate overall ad performance metrics
WITH metrics AS (
    SELECT
        SUM(CASE WHEN event_type = 'impression' THEN 1 ELSE 0 END) AS impressions,
        SUM(CASE WHEN event_type = 'click' THEN 1 ELSE 0 END) AS clicks,
        SUM(CASE WHEN event_type = 'comment' THEN 1 ELSE 0 END) AS comments,
        SUM(CASE WHEN event_type = 'share' THEN 1 ELSE 0 END) AS shares,
        SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchases
    FROM ad_events
)
SELECT
    impressions,
    clicks,
    comments,
    shares,
    purchases,
    comments + shares + clicks AS engagements,
    ROUND(clicks * 100.0 / NULLIF(impressions,0),2) AS ctr,
    ROUND((comments + shares + clicks) * 100.0 / NULLIF(impressions,0),2) AS engagement_rate,
    ROUND(purchases * 100.0 / NULLIF(clicks,0),2) AS conversion_rate,
    ROUND(purchases * 100.0 / NULLIF(impressions,0),2) AS purchase_rate
FROM metrics;


2. Total Budget & Average Budget
SELECT
    SUM(total_budget) AS total_budget,
    AVG(total_budget) AS avg_budget
FROM campaigns;


3. Impressions by Gender (Donut Chart)
SELECT
    u.user_gender,
    COUNT(*) AS impressions
FROM ad_events ae
JOIN users u
    ON ae.user_id = u.user_id
WHERE ae.event_type = 'impression'
GROUP BY u.user_gender
ORDER BY impressions DESC;


4. Impressions by Age
SELECT
    u.user_age,
    COUNT(*) AS impressions
FROM ad_events ae
JOIN users u
    ON ae.user_id = u.user_id
WHERE ae.event_type = 'impression'
GROUP BY u.user_age
ORDER BY u.user_age;


5. Impressions by Age Group
SELECT
    u.age_group,
    COUNT(*) AS impressions
FROM ad_events ae
JOIN users u
    ON ae.user_id = u.user_id
WHERE ae.event_type = 'impression'
GROUP BY u.age_group
ORDER BY impressions DESC;


6. Weekly Impressions Trend
SELECT
    DATEPART(WEEK, event_date) AS week_no,
    COUNT(*) AS impressions
FROM ad_events
WHERE event_type = 'impression'
GROUP BY DATEPART(WEEK, event_date)
ORDER BY week_no;


7. Hourly Impressions
SELECT
    event_hour,
    COUNT(*) AS impressions
FROM ad_events
WHERE event_type = 'impression'
GROUP BY event_hour
ORDER BY event_hour;


8. Users by Country
SELECT
    country,
    COUNT(DISTINCT user_id) AS total_users
FROM users
GROUP BY country
ORDER BY total_users DESC;


9. Impressions by Month (Calendar Heatmap)
SELECT
    MONTH(event_date) AS month_no,
    DATENAME(MONTH,event_date) AS month_name,
    COUNT(*) AS impressions
FROM ad_events
WHERE event_type='impression'
GROUP BY
    MONTH(event_date),
    DATENAME(MONTH,event_date)
ORDER BY month_no;


10. Daily Impressions Calendar
SELECT
    event_date,
    DATENAME(WEEKDAY,event_date) AS weekday_name,
    COUNT(*) AS impressions
FROM ad_events
WHERE event_type='impression'
GROUP BY
    event_date,
    DATENAME(WEEKDAY,event_date)
ORDER BY event_date;


11. Ad Type Performance Table

This powers the bottom-right matrix.

SELECT
    a.ad_type,

    SUM(CASE WHEN ae.event_type='impression' THEN 1 ELSE 0 END) AS impressions,

    SUM(CASE WHEN ae.event_type='click' THEN 1 ELSE 0 END) AS clicks,

    ROUND(
        SUM(CASE WHEN ae.event_type='click' THEN 1 ELSE 0 END)*100.0/
        NULLIF(SUM(CASE WHEN ae.event_type='impression' THEN 1 ELSE 0 END),0)
    ,2) AS CTR,

    SUM(CASE WHEN ae.event_type='purchase' THEN 1 ELSE 0 END) AS purchases,

    ROUND(
        (
            SUM(CASE WHEN ae.event_type='comment' THEN 1 ELSE 0 END)+
            SUM(CASE WHEN ae.event_type='share' THEN 1 ELSE 0 END)+
            SUM(CASE WHEN ae.event_type='click' THEN 1 ELSE 0 END)
        ) *100.0 /
        NULLIF(SUM(CASE WHEN ae.event_type='impression' THEN 1 ELSE 0 END),0)
    ,2) AS EngagementRate,

    ROUND(
        SUM(CASE WHEN ae.event_type='purchase' THEN 1 ELSE 0 END)*100.0/
        NULLIF(SUM(CASE WHEN ae.event_type='click' THEN 1 ELSE 0 END),0)
    ,2) AS ConversionRate

FROM ads a
JOIN ad_events ae
    ON a.ad_id = ae.ad_id

GROUP BY a.ad_type
ORDER BY impressions DESC;


12. Video Ads Performance
SELECT
    COUNT(CASE WHEN ae.event_type='impression' THEN 1 END) AS impressions,
    COUNT(CASE WHEN ae.event_type='click' THEN 1 END) AS clicks,
    COUNT(CASE WHEN ae.event_type='purchase' THEN 1 END) AS purchases
FROM ads a
JOIN ad_events ae
    ON a.ad_id = ae.ad_id
WHERE a.ad_type='Video';


13. Image Ads Performance
SELECT
    COUNT(CASE WHEN ae.event_type='impression' THEN 1 END) AS impressions,
    COUNT(CASE WHEN ae.event_type='click' THEN 1 END) AS clicks,
    COUNT(CASE WHEN ae.event_type='purchase' THEN 1 END) AS purchases
FROM ads a
JOIN ad_events ae
    ON a.ad_id = ae.ad_id
WHERE a.ad_type='Image';


14. Stories Ads Performance
SELECT
    COUNT(CASE WHEN ae.event_type='impression' THEN 1 END) AS impressions,
    COUNT(CASE WHEN ae.event_type='click' THEN 1 END) AS clicks,
    COUNT(CASE WHEN ae.event_type='purchase' THEN 1 END) AS purchases
FROM ads a
JOIN ad_events ae
    ON a.ad_id = ae.ad_id
WHERE a.ad_type='Stories';


15. Carousel Ads Performance
SELECT
    COUNT(CASE WHEN ae.event_type='impression' THEN 1 END) AS impressions,
    COUNT(CASE WHEN ae.event_type='click' THEN 1 END) AS clicks,
    COUNT(CASE WHEN ae.event_type='purchase' THEN 1 END) AS purchases
FROM ads a
JOIN ad_events ae
    ON a.ad_id = ae.ad_id
WHERE a.ad_type='Carousel';


16. Budget Allocation by Ad Type
SELECT
    a.ad_type,
    SUM(c.total_budget) AS allocated_budget
FROM ads a
JOIN campaigns c
    ON a.compaign_id = c.campaigns_id
GROUP BY a.ad_type
ORDER BY allocated_budget DESC;


17. Performance vs Spend
SELECT
    a.ad_type,
    SUM(c.total_budget) AS budget,
    SUM(CASE WHEN ae.event_type='impression' THEN 1 ELSE 0 END) AS impressions,
    SUM(CASE WHEN ae.event_type='click' THEN 1 ELSE 0 END) AS clicks,
    SUM(CASE WHEN ae.event_type='purchase' THEN 1 ELSE 0 END) AS purchases
FROM ads a
JOIN campaigns c
    ON a.compaign_id = c.campaigns_id
JOIN ad_events ae
    ON a.ad_id = ae.ad_id
GROUP BY a.ad_type;


18. Platform Performance (Facebook vs Instagram)
SELECT
    ad_plantform,
    SUM(CASE WHEN ae.event_type='impression' THEN 1 ELSE 0 END) AS impressions,
    SUM(CASE WHEN ae.event_type='click' THEN 1 ELSE 0 END) AS clicks,
    SUM(CASE WHEN ae.event_type='purchase' THEN 1 ELSE 0 END) AS purchases
FROM ads a
JOIN ad_events ae
    ON a.ad_id = ae.ad_id
GROUP BY ad_plantform;