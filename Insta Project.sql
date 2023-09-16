-- Instagram User Analytics
-- Description
-- User analysis is the process by which we track how users engage and interact with our digital 
-- product (software or mobile applications)
-- in an attempt to derive business insights for marketing, product & development teams.


USE ig_clone;

/*Users*/
CREATE TABLE users(
	id INT AUTO_INCREMENT UNIQUE PRIMARY KEY,
	username VARCHAR(255) NOT NULL,
	created_at TIMESTAMP DEFAULT NOW()
);

/*Photos*/
CREATE TABLE photos(
	id INT AUTO_INCREMENT PRIMARY KEY,
	image_url VARCHAR(355) NOT NULL,
	user_id INT NOT NULL,
	created_dat TIMESTAMP DEFAULT NOW(),
	FOREIGN KEY(user_id) REFERENCES users(id)
);

/*Comments*/
CREATE TABLE comments(
	id INT AUTO_INCREMENT PRIMARY KEY,
	comment_text VARCHAR(255) NOT NULL,
	user_id INT NOT NULL,
	photo_id INT NOT NULL,
	created_at TIMESTAMP DEFAULT NOW(),
	FOREIGN KEY(user_id) REFERENCES users(id),
	FOREIGN KEY(photo_id) REFERENCES photos(id)
);

/*Likes*/
CREATE TABLE likes(
	user_id INT NOT NULL,
	photo_id INT NOT NULL,
	created_at TIMESTAMP DEFAULT NOW(),
	FOREIGN KEY(user_id) REFERENCES users(id),
	FOREIGN KEY(photo_id) REFERENCES photos(id),
	PRIMARY KEY(user_id,photo_id)
);

/*follows*/
CREATE TABLE follows(
	follower_id INT NOT NULL,
	followee_id INT NOT NULL,
	created_at TIMESTAMP DEFAULT NOW(),
	FOREIGN KEY (follower_id) REFERENCES users(id),
	FOREIGN KEY (followee_id) REFERENCES users(id),
	PRIMARY KEY(follower_id,followee_id)
);

/*Tags*/
CREATE TABLE tags(
	id INTEGER AUTO_INCREMENT PRIMARY KEY,
	tag_name VARCHAR(255) UNIQUE NOT NULL,
	created_at TIMESTAMP DEFAULT NOW()
);

/*junction table: Photos - Tags*/
CREATE TABLE photo_tags(
	photo_id INT NOT NULL,
	tag_id INT NOT NULL,
	FOREIGN KEY(photo_id) REFERENCES photos(id),
	FOREIGN KEY(tag_id) REFERENCES tags(id),
	PRIMARY KEY(photo_id,tag_id)
);


-- 1. Find the 5 oldest users of the Instagram from the database provided
select * from users;
select username, created_at from users order by created_at limit 5;

-- 2. Find the users who have never posted a single photo on Instagram
select * from photos,users;
select * from users u left join photos p on p.user_id = u.id where p.image_url is null order by u.username;

-- 3. Identify the winner of the contest and provide their details to the team
select * from likes,photos,users;

select likes.photo_id,users.username, count(likes.user_id) as likess
from likes inner join photos on likes.photo_id = photos.id
inner join users on photos.user_id = users.id group by
likes.photo_id,users.username order by likess desc;

-- 4. Identify and suggest the top 5 most commonly used hashtags on the platforms
select * from photo_tags,tags;
select t.tag_name,count(p.photo_id) as ht from photo_tags p inner join tags t on t.id = p.tag_id group by t.tag_name order by ht desc limit 5;

-- 5. What day of the week do most users register on? Provide insights on when to schedule an ad campaign
select * from users;
select date_format((created_at), '%W') as d,count(username) from users group by 1 order by 2 desc;

-- 6. Provide how many times does average user posts on Instagram. Also, provide the total number of photos on Instagram/ total numbers of users
select * from photos,users;
with base as (
select u.id as userid, count(p.id) as photoid from users u left join photos p on p.user_id=u.id group by u.id)
select sum(photoid) as totalphotos,count(userid) as total_users,sum(photoid)/count(userid) as photoperuser from base;

-- 7. Provide data on users (bots) who have liked every single photo on the site (since any normal user would not be able to do this).
select * from users,likes;
with base as (
select u.username,count(l.photo_id) as likess from likes l inner join users u on u.id=l.user_id group by u.username)
select username,likess from base where likess=(select count(*) from photos) order by username;