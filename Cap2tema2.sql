select 
ad_date, campaign_id,
sum(spend) as "total spend", sum(impressions) as "total impressions", sum(clicks)as "total clicks", sum(leads) as "total leads",
sum(spend) / sum(clicks)::float as "CPC",
sum(spend) / sum(impressions)::float *1000 as "CPN",
sum(clicks) / sum(impressions)::float *100 as "CTR",
(sum(value) - sum(spend))/sum(spend)::float as "ROMI"
from public.facebook_ads_basic_daily
where CLICKS>0
 AND campaign_id IN (
        SELECT campaign_id
        FROM public.facebook_ads_basic_daily
        GROUP BY campaign_id
        HAVING SUM(spend) > 500000
    )
GROUP BY
    ad_date, campaign_id
ORDER BY
    (SUM(value) - SUM(spend)) / SUM(spend)::float DESC
LIMIT 1;