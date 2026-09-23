-- Table Keys

ALTER TABLE baristas
ADD CONSTRAINT PK_baristas PRIMARY KEY (baristaID);

ALTER TABLE shops
ADD CONSTRAINT PK_shops PRIMARY KEY (shopID);

ALTER TABLE pastries
ADD CONSTRAINT PK_pastries PRIMARY KEY (pastryID);

ALTER TABLE employs
ADD CONSTRAINT FK_employs FOREIGN KEY (baristaID) REFERENCES baristas(baristaID),
ADD CONSTRAINT FK2_employs FOREIGN KEY (shopID) REFERENCES shops(shopID);

ALTER TABLE offers
ADD CONSTRAINT FK_offers FOREIGN KEY (pastryID) REFERENCES pastries(pastryID),
ADD CONSTRAINT FK2_offers FOREIGN KEY (shopID) REFERENCES shops(shopID);

-- 1.
select p.category, ROUND(avg(p.price), 2) as average_price from pastries p
group by p.category;

-- 2.
select b.experience_level, count(b.name) as experience_count from baristas b
group by b.experience_level;

-- 3.
select s.city, count(s.name) as shop_density from shops s
group by s.city;

-- 4.
select p.category, max(p.price) as max_price from pastries p
group by p.category;

-- 5. 
select o.shopID, count(o.pastryID) as pastry_options from offers o
group by o.shopID;

-- 6. 
select p.category, p.name, p.price from pastries p
where p.price in (
select max(p.price)from pastries p
group by p.category
)
group by p.name, p.category, p.price;

-- 7.
select distinct o.shopID
from offers o
left join pastries p on o.pastryID = p.pastryID
where p.price > (
select avg(p.price) from pastries p
)
group by o.shopID;

-- 8. 
select o.shopID, o.pastryID
from offers o
where o.date_added = (
select min(o.date_added) from offers o
)
group by o.shopID, o.pastryID;

-- 9. 
select distinct o.shopID from offers o
group by o.shopID
having count(o.pastryID) = (
select count(o.pastryID) from offers o
group by o.shopID
limit 1 
);

-- 10. 
select b.name from baristas b
left join employs e on b.baristaID = e.baristaID
where b.baristaID in (
select e.baristaID from employs e
where e.shopID = 1
)
group by b.name;