with CombinedData as (
select 
fabd.ad_date,
fc.campaign_name,
fas.adset_name,
fabd.spend,
fabd.impressions,
fabd.reach,
fabd.clicks,
fabd.leads,
fabd.value
from
facebook_ads_basic_daily fabd 
left join
facebook_campaign fc ON fc.campaign_id = fabd.campaign_id
    LEFT JOIN
        facebook_adset fas ON fas.adset_id = fabd.adset_id
union all
select ad_date, campaign_name, adset_name, spend, impressions, reach, clicks, leads, value 
from
google_ads_basic_daily 
)
select
 ad_date,
 campaign_name,
 adset_name,
 sum(spend) as total_spend,
 sum(impressions) as total_impressions,
 sum(reach) as tota_reach,
 sum(clicks) as total_clicks,
 sum(leads) as total_leads,
 sum(value) as total_value
 from
 CombinedData
 group by 
 ad_date, campaign_name, adset_name ;

