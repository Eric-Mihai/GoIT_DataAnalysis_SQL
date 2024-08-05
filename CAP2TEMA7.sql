WITH CTE1 AS (
    SELECT
        COALESCE(facebook_ads_basic_daily.ad_date, google_ads_basic_daily.ad_date) AS ad_date,
        COALESCE(facebook_ads_basic_daily.url_parameters, google_ads_basic_daily.url_parameters) AS url_parameters,
        COALESCE(facebook_ads_basic_daily.spend, 0) AS spend,
        COALESCE(facebook_ads_basic_daily.impressions, 0) AS impressions,
        COALESCE(facebook_ads_basic_daily.reach, 0) AS reach,
        COALESCE(facebook_ads_basic_daily.clicks, 0) AS clicks,
        COALESCE(facebook_ads_basic_daily.leads, 0) AS leads,
        COALESCE(facebook_ads_basic_daily.value, 0) AS value
    FROM
        facebook_ads_basic_daily
    FULL JOIN
        google_ads_basic_daily ON facebook_ads_basic_daily.ad_date = google_ads_basic_daily.ad_date
),
CTE2 AS (
    SELECT
        DATE_TRUNC('month', ad_date) AS ad_month,
        LOWER((REGEXP_MATCHES(url_parameters, 'utm_campaign=([^&]*)', 'i'))[1]) AS utm_campaign,
        SUM(spend) AS total_spend,
        SUM(impressions) AS total_impressions,
        SUM(clicks) AS total_clicks,
        SUM(leads) AS total_leads,
        case
            when SUM(impressions) > 0 then SUM(clicks)::numeric/sum(impressions)
        end as CTR,
        CASE
            WHEN SUM(clicks) > 0 THEN SUM(spend) / NULLIF(SUM(clicks), 0)
            ELSE 0
        END AS CPC,
        CASE
            WHEN SUM(impressions) > 0 THEN SUM(spend) / NULLIF((SUM(impressions) / 1000), 0)
            ELSE 0
        END AS CPM,
        CASE
            WHEN SUM(spend) > 0 THEN SUM(value) / NULLIF(SUM(spend), 0) * 100
            ELSE 0
        END AS ROMI
    FROM
        CTE1
    GROUP BY
        ad_month, url_parameters
),
Lags as(
    select  *,
    LAG(CPM) OVER(PARTITION BY utm_campaign ORDER BY ad_month) AS previous_month_cpm,
    LAG(CTR) OVER(PARTITION BY utm_campaign ORDER BY ad_month) AS previous_month_ctr,
    LAG(ROMI) OVER(PARTITION BY utm_campaign ORDER BY ad_month) AS previous_month_romi
    from CTE2
)
SELECT *,
    case
        when previous_month_cpm > 0 then cpm::numeric / previous_month_cpm - 1
        when previous_month_cpm = 0 and cpm > 0 then 1
    end as cpm_change,
    case
        when previous_month_ctr > 0 then ctr::numeric / previous_month_ctr - 1
        when previous_month_ctr = 0 and ctr > 0 then 1
    end as ctr_change,
    case
        when previous_month_romi > 0 then romi::numeric / previous_month_romi - 1
        when previous_month_romi = 0 and romi > 0 then 1
    end as romi_change
FROM
    Lags;