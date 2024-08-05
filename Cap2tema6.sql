WITH CTE1 AS (
    SELECT
        COALESCE(fb.ad_date, gg.ad_date) AS ad_date,
        COALESCE(fb.url_parameters, gg.url_parameters) AS url_parameters,
        COALESCE(fb.spend, 0) AS spend,
        COALESCE(fb.impressions, 0) AS impressions,
        COALESCE(fb.reach, 0) AS reach,
        COALESCE(fb.clicks, 0) AS clicks,
        COALESCE(fb.leads, 0) AS leads,
        COALESCE(fb.value, 0) AS value
    FROM
        facebook_ads_basic_daily fb
    FULL JOIN
        google_ads_basic_daily gg ON fb.ad_date = gg.ad_date
)
SELECT
 ad_date,
    LOWER((REGEXP_MATCHES(url_parameters, 'utm_campaign=([^&]*)', 'i'))[1]) AS utm_campaign,
    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(leads) AS total_leads,
    CASE
        WHEN SUM(impressions) > 0 THEN SUM(clicks) / NULLIF(SUM(impressions), 0) * 100
        ELSE 0
    END AS ctr,
    CASE
        WHEN SUM(clicks) > 0 THEN SUM(spend) / NULLIF(SUM(clicks), 0)
        ELSE 0
    END AS cpc,
    CASE
        WHEN SUM(impressions) > 0 THEN SUM(spend) / NULLIF((SUM(impressions) / 1000), 0)
        ELSE 0
    END AS cpm,
    CASE
        WHEN SUM(spend) > 0 THEN SUM(value) / NULLIF(SUM(spend), 0) * 100
        ELSE 0
    END AS romi
FROM
    CTE1
GROUP BY
    ad_date, utm_campaign;