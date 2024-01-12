CREATE TABLE `posts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` text,
  `content` text,
  `image` text,
  `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`)
);
