select a.* from
(select d1.*, d2.`referenced-count`, d1.`reference-count`*0.2+d1.`relate-count`+d2.`referenced-count`*20-d1.`from-now`*0.005 as "total-count" from
(select t1.id, t1.title, t1.author, t1.publish_time, t1.tags, datediff(now(), t1.publish_time) as "from-now", t1.`reference-count`, ifnull(t2.`relate-count`, 0) as "relate-count", t1.href from
  (select a.id, a.title, a.author, a.publish_time, count(b.id) as "reference-count", a.href, a.tags from SpiderDoc_golangblog a left join SpiderDoc_golangreferencearticle b on b.source_id = a.id group by a.id) t1
  left join
  (select b.source_id, count(b.id) as "relate-count" from SpiderDoc_golangblog a left join SpiderDoc_golangrelatedarticle b on b.source_id = a.id group by b.source_id) t2
  on t1.id = t2.source_id
) d1
left join
(
  select sum(c.tag) as "referenced-count",c.`href` from (
                                  select a.id, a.href, b.href as "href2", b.source_id, if(b.href is not null, 1,0) as "tag" from SpiderDoc_golangblog a left join SpiderDoc_golangreferencearticle b on a.href = b.href
                                ) as c GROUP BY c.`href`
) d2
on d2.href=d1.href
order by `total-count` DESC, `referenced-count` DESC) as a
where a.tags not LIKE "%gopher%" and a.tags not like "%community%" and a.tags != "" and a.tags not like "%talk%" and a.tags not like "%release%"
;
