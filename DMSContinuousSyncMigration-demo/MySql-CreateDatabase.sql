CREATE TABLE `inventory`.`catalog` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(200) NOT NULL,
  `description` TEXT NULL,
  `category` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id`));
  
  CREATE TABLE `inventory`.`orders` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `catalogid` INT NOT NULL,
  `orderdate` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `quantity` INT NOT NULL,
  PRIMARY KEY (`id`));
  
  CREATE VIEW order_view AS SELECT o.id, c.name, o.orderdate, o.quantity FROM orders o, catalog c where o.catalogid = c.id order by id desc;