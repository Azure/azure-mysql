-- MySQL dump 10.13  Distrib 8.0.26, for Win64 (x86_64)
--
-- Host: localhost    Database: contosostore
-- ------------------------------------------------------
-- Server version	8.0.27

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cart_items`
--

DROP TABLE IF EXISTS `cart_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `cart` int NOT NULL,
  `item` int NOT NULL,
  `qty` smallint unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart_items`
--

LOCK TABLES `cart_items` WRITE;
/*!40000 ALTER TABLE `cart_items` DISABLE KEYS */;
INSERT INTO `cart_items` VALUES (1,1,4,1),(2,2,14,1),(3,2,12,1);
/*!40000 ALTER TABLE `cart_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `carts`
--

DROP TABLE IF EXISTS `carts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `carts` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user` int NOT NULL,
  `status` varchar(16) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `carts`
--

LOCK TABLES `carts` WRITE;
/*!40000 ALTER TABLE `carts` DISABLE KEYS */;
INSERT INTO `carts` VALUES (1,1,'closed'),(2,1,'closed');
/*!40000 ALTER TABLE `carts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `url` varchar(32) NOT NULL,
  `img` varchar(128) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,'Breakfast','breakfast','potatoes-g792cf4128_1920.jpg'),(2,'Steak','steak','tomahawk-ge5ea2413d_1920.jpg'),(3,'Pizza','pizza','pizza-g204a8b3d6_1920.jpg'),(4,'Burgers','burgers','hamburger-g685f013b8_1920.jpg'),(5,'Sushi','sushi','food-g3eb975adc_1920.jpg'),(6,'Salads','salads','salad-g3f02f56a0_1920.jpg');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `items`
--

DROP TABLE IF EXISTS `items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `category` int NOT NULL,
  `name` varchar(32) NOT NULL,
  `img` varchar(128) NOT NULL,
  `price` decimal(6,2) NOT NULL,
  `cooktime` smallint unsigned NOT NULL,
  `desc` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `items`
--

LOCK TABLES `items` WRITE;
/*!40000 ALTER TABLE `items` DISABLE KEYS */;
INSERT INTO `items` VALUES (1,1,'Cinnamon Roll','cinnamon-rolls-gb12ce8577_1920.jpg',1.19,13,'Cupcake ipsum dolor sit amet dragée topping topping. Powder cheesecake cake shortbread gummies lollipop jelly carrot cake. Pudding sugar plum carrot cake I love muffin. Dessert topping croissant I love tart soufflé cheesecake sweet sweet. Liquorice pie marshmallow icing topping muffin. Topping brownie oat cake carrot cake donut chocolate bar cake. Bear claw jelly-o ice cream lollipop shortbread dessert jujubes macaroon. I love danish tootsie roll powder candy canes marzipan icing gingerbread chocolate bar.'),(2,1,'Toast & Eggs','breakfast-g7a2675ee6_1920.jpg',2.19,7,'Tiramisu muffin sweet roll cotton candy icing bonbon jelly. Tiramisu oat cake shortbread toffee bonbon shortbread candy canes toffee. Sweet roll biscuit I love oat cake gummies bonbon biscuit danish lemon drops. Toffee ice cream jelly beans caramels muffin. Tart jujubes chocolate bar marshmallow gingerbread I love pie. Chocolate I love chocolate cake cake liquorice lollipop. Tiramisu chocolate jelly-o muffin halvah. Shortbread soufflé ice cream oat cake cotton candy sesame snaps liquorice. Danish marzipan I love jelly brownie muffin halvah candy canes.'),(3,1,'Croissant','croissant-ga61b1fb0e_1920.jpg',3.19,2,'I love chocolate cake I love I love jelly beans cotton candy jelly-o ice cream. Icing cotton candy sweet roll fruitcake biscuit apple pie. Gummies chocolate caramels biscuit I love I love I love cookie croissant. Topping apple pie wafer sesame snaps tootsie roll gummies. Apple pie I love wafer sweet roll tootsie roll. Cheesecake I love apple pie muffin tiramisu lemon drops cake. Macaroon caramels chocolate cotton candy soufflé tart. Chupa chups lemon drops cupcake topping pastry.'),(4,1,'Bacon & Eggs','eggs-g9c07e92b1_1920.jpg',4.19,14,'Toffee sesame snaps chupa chups pie pastry marshmallow I love tootsie roll soufflé. Marshmallow fruitcake cheesecake I love icing cake. Liquorice toffee chocolate bar marzipan cotton candy croissant powder. Bonbon I love danish bear claw tootsie roll. Candy canes wafer fruitcake caramels lollipop tart. Oat cake croissant tart gummi bears cookie muffin. Icing sweet roll chupa chups chupa chups jelly-o brownie. Jelly-o cotton candy liquorice tiramisu halvah jujubes.'),(5,1,'Pancakes','pancakes-g9d341228a_1920.jpg',5.19,12,'Chocolate caramels gingerbread dragée gingerbread brownie powder gummi bears pastry. Sugar plum sugar plum tootsie roll shortbread I love cotton candy. Chocolate cake chocolate bonbon cake biscuit. Toffee cheesecake I love cookie cake marzipan I love chocolate cake liquorice. Biscuit biscuit caramels macaroon lollipop powder tootsie roll. Shortbread jelly-o jujubes jelly-o chocolate carrot cake danish croissant. Biscuit jelly-o donut bonbon muffin carrot cake sesame snaps wafer chupa chups. Chupa chups chocolate bar bonbon I love jelly beans lemon drops macaroon muffin. Chocolate cake cookie jelly-o cake cake croissant muffin halvah candy. Apple pie icing pudding chupa chups macaroon I love biscuit fruitcake I love.'),(6,1,'Biscuits & Gravy','biscuits-g07bd069f8_1920.jpg',6.19,6,'Soufflé marshmallow I love candy canes I love apple pie. Icing wafer I love toffee carrot cake cookie candy canes bear claw pastry. Lollipop topping pudding dessert powder jujubes sesame snaps bonbon apple pie. Macaroon tootsie roll dessert cake I love wafer macaroon sweet roll sesame snaps. Wafer cupcake bear claw sweet brownie I love. Pastry I love muffin marzipan I love topping. Pie candy muffin jelly-o croissant cake sweet. Wafer chocolate lemon drops jujubes lollipop dragée I love jelly. I love macaroon I love powder tootsie roll jelly muffin wafer.'),(7,2,'Tomahawk','steak-4342500_1920.jpg',1.29,27,'Bacon ipsum dolor amet shank picanha landjaeger kevin, ham hock spare ribs sausage capicola buffalo alcatra. Short loin spare ribs alcatra bresaola. Salami tongue drumstick tenderloin flank alcatra shank sirloin biltong landjaeger short ribs jerky. Porchetta meatloaf fatback frankfurter bacon tail, ham biltong kielbasa short ribs pork capicola leberkas jowl. Chicken tenderloin kielbasa pork belly, ham hock jowl bacon salami chuck burgdoggen hamburger tongue short loin biltong. Frankfurter sirloin meatloaf ribeye.'),(8,2,'Sirloin','steak-1076665_1920.jpg',2.29,22,'Meatball fatback pastrami, porchetta doner chicken burgdoggen pancetta jerky beef ribs salami. Buffalo ball tip tenderloin chuck, frankfurter alcatra ribeye t-bone spare ribs. Hamburger pork chop swine, picanha flank corned beef burgdoggen shoulder frankfurter ham ball tip. Chicken biltong short ribs short loin spare ribs. Pork loin jerky pork chop, fatback frankfurter filet mignon turducken kevin swine. Prosciutto kielbasa short ribs shoulder frankfurter hamburger. Swine leberkas alcatra jerky, ball tip pastrami meatloaf pork belly doner venison turkey buffalo ham hock pig.'),(9,2,'T-Bone','steak-978654_1920.jpg',3.29,23,'Swine doner leberkas tri-tip pork loin hamburger cupim alcatra spare ribs kielbasa bacon. Shoulder tail alcatra meatloaf beef hamburger, short loin tri-tip cupim ham pork chop. Corned beef kevin strip steak tri-tip. Landjaeger meatball chuck biltong salami fatback jerky pastrami shank beef. Frankfurter ground round strip steak pork chop shoulder, picanha pig doner prosciutto chislic ham. Ham hock alcatra shankle chislic rump landjaeger brisket pork leberkas t-bone meatloaf pancetta pork loin.'),(10,3,'Pepperoni','pizza-1344720_1920.jpg',1.39,12,'Gouda mozzarella babybel. Jarlsberg emmental who moved my cheese cauliflower cheese brie cheesy feet airedale swiss. Port-salut bocconcini monterey jack squirty cheese cut the cheese say cheese cauliflower cheese lancashire. Who moved my cheese who moved my cheese taleggio cheesy feet cheeseburger hard cheese emmental.'),(11,3,'Margherita','pizza-3000274_1920.jpg',2.39,6,'I love cheese, especially who moved my cheese fondue. Parmesan cheese slices the big cheese cheese strings jarlsberg fromage ricotta red leicester. Queso everyone loves cheesecake everyone loves who moved my cheese red leicester fondue smelly cheese. Mozzarella goat blue castello swiss cheese slices hard cheese swiss cow. Cream cheese swiss.'),(12,4,'Sliders','hamburger-494706_1920.jpg',1.49,9,'Ribeye ball tip kevin tri-tip beef biltong. Pastrami pork belly burgdoggen, sirloin bresaola andouille flank fatback short ribs chuck shoulder tongue boudin strip steak. Bacon pancetta biltong kielbasa, cow shank sausage rump chuck spare ribs alcatra ground round meatball chicken strip steak. Sirloin andouille pig ham hock swine kielbasa salami tongue meatball cupim jowl. Cow fatback drumstick picanha ball tip. Meatloaf venison shankle rump, tail tenderloin short ribs.'),(13,4,'Charbroiled','hamburger-1238246_1920.jpg',2.49,17,'Kielbasa boudin alcatra, beef ribs spare ribs rump pork belly pork chop salami ribeye pancetta. Alcatra picanha ground round, frankfurter short loin porchetta leberkas venison cow fatback landjaeger rump boudin. Flank t-bone kielbasa burgdoggen short ribs landjaeger tenderloin ham hock pastrami. Burgdoggen turducken landjaeger, short ribs frankfurter tail brisket chuck shoulder buffalo sausage doner rump. Swine ground round ribeye ham hock tongue turducken sirloin, burgdoggen sausage shank t-bone cupim.'),(14,4,'Diner Burger','burger-3442227_1920.jpg',3.49,12,'Fatback drumstick filet mignon, frankfurter chicken pork meatloaf pork belly venison jerky beef pork loin ham hock biltong. Pork chop ham andouille ground round hamburger. Beef ribs ground round cow pig biltong short ribs sirloin spare ribs. Fatback pork chop cow filet mignon burgdoggen doner picanha swine tongue, tail corned beef meatball pancetta pork.'),(15,5,'Sashimi Fresh Roll','sushi-354628_1920.jpg',1.59,3,'Barbelless catfish eel-goby spiny eel yellowtail snapper mullet minnow white marlin northern pike bigeye? Sauger sandroller; hoki sixgill ray squawfish sailfin silverside. Olive flounder giant danio herring smelt tailor Australasian salmon barbeled houndshark southern grayling porbeagle shark roundhead.'),(16,5,'Power Fish','sushi-2853382_1920.jpg',2.59,5,'Atlantic silverside jewfish shovelnose sturgeon huchen temperate ocean-bass mullet menhaden stargazer yellowtail orangestriped triggerfish bluefin tuna. Arapaima plunderfish arapaima, mudskipper, earthworm eel snubnose eel Pacific viperfish tripletail.'),(17,5,'Spicy Tuna','sushi-599721_1920.jpg',3.59,7,'Elephantnose fish bango longjaw mudsucker; sand stargazer? Dragonet: kissing gourami tench demoiselle; bullhead shark lookdown catfish halibut tubeblenny southern flounder, hairtail gray reef shark. Long-whiskered catfish lake whitefish, worm eel Ratfish European minnow! Javelin temperate perch sandroller waryfish pikehead gouramie longnose dace starry flounder medusafish cusk-eel.'),(18,5,'Avocado Roll','maki-716432_1920.jpg',4.59,2,'Wormfish, glowlight danio Atlantic cod ide flagblenny, ribbon sawtail fish Kafue pike southern grayling. Speckled trout grayling ling nurseryfish threadfin. Snake eel char sturgeon scissor-tail rasbora blue eye worm eel southern smelt. Salmon jellynose fish, buffalofish lanternfish kaluga duckbill eel. Swampfish halosaur flashlight fish wahoo popeye catafula pirarucu; torpedo; rock beauty longnose chimaera elver thornfish, rough scad! Pipefish tompot blenny Kafue pike large-eye bream elasmobranch northern lampfish soapfish rocket danio mudskipper smalltooth sawfish.'),(19,5,'Sampler Plate','sushi-2856545_1920.jpg',5.59,4,'Poolfish waryfish frilled shark louvar, wasp fish blue catfish Molly Miller Black scalyfin gizzard shad, platyfish, common carp. Tiger shark roanoke bass milkfish yellowhead jawfish, round stingray sea bass surfperch treefish Asiatic glassfish. Silver carp scissor-tail rasbora pompano dolphinfish: frogmouth catfish mackerel shark. Perch hardhead catfish sand stargazer: goosefish wolf-herring.'),(20,5,'Veggie Roll','sushi-2020287_1920.jpg',6.59,2,'Stingray, tarpon; clown triggerfish plaice pleco wrasse Pacific herring kuhli loach rough scad, burma danio. River stingray weasel shark popeye catafula Australian grayling remora flying gurnard smalltooth sawfish, dwarf loach pike conger. Thornyhead megamouth shark pencilfish blacktip reef shark Atlantic silverside Black pickerel, electric eel spiderfish bass electric catfish? Peamouth tetra lightfish midshipman monkfish spearfish burrowing goby trahira, collared dogfish yellow weaver driftfish, dorab roosterfish, sea bream.'),(21,5,'Maki','sushi-748139_1920.jpg',7.59,5,'Angler, swampfish orangestriped triggerfish oceanic flyingfish northern anchovy smooth dogfish. Bigscale pomfret stonefish pollyfish warmouth; round herring banded killifish. Walking catfish, weever cod: Antarctic icefish slimy sculpin.'),(22,6,'Bowl of Lettuce','food-1834645_1920.jpg',1.69,1,'Carrot grape soko wakame plantain pea broccoli rabe desert raisin. Chard cabbage cress gumbo spinach mung bean turnip greens rock melon chicory collard greens bok choy. Wattle seed wakame eggplant soybean quandong garlic prairie turnip swiss chard radish okra.'),(23,6,'Plate of Lettuce','salad-2150548_1920.jpg',2.69,1,'Nori grape silver beet broccoli kombu beet greens fava bean potato quandong celery. Bunya nuts black-eyed pea prairie turnip leek lentil turnip greens parsnip. Sea lettuce lettuce water chestnut eggplant winter purslane fennel azuki bean earthnut pea sierra leone bologi leek soko chicory celtuce parsley jícama salsify.');
/*!40000 ALTER TABLE `items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'2019_12_14_000001_create_personal_access_tokens_table',1),(2,'2021_12_10_165212_create_category_table',1),(3,'2021_12_10_165231_create_item_table',1),(4,'2021_12_10_165446_create_cart_table',1),(5,'2021_12_10_170008_create_user_table',1),(6,'2021_12_10_170023_create_order_table',1),(7,'2021_12_16_030021_create_cart_items_table',1);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user` int NOT NULL,
  `cart` int NOT NULL,
  `name` varchar(64) NOT NULL,
  `address` varchar(256) NOT NULL,
  `special_instructions` text,
  `cooktime` smallint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,1,1,'Bob Slydell','820 Beach Street',NULL,22,'2022-01-03 23:42:19','2022-01-03 23:42:19'),(2,1,2,'Bob Slydell','820 Beach Street',NULL,19,'2022-01-03 23:43:07','2022-01-03 23:43:07');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `address` varchar(256) NOT NULL,
  `email` varchar(128) NOT NULL,
  `password` varchar(128) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Peter Gibbons','97 Walt Whitman Street','pgibbons@contoso-noshnow.com','$2y$10$to15mfd3prPS3fpak9RIMuArLKY0GfaJAfLt61FjdoN0rBd2kgQLu'),(2,'Michael Bolton','7756 Princeton Street','mbolton@contoso-noshnow.com','$2y$10$fTGe1JGZGgQ/IMSRWk6vNOF0z5DJsiUXfQM1IQDTIfOV4ZfNgmx7e'),(3,'Samir Nagheenanajar','7583 Honey Creek St.','snagheenanajar@contoso-noshnow.com','$2y$10$2DMlLQwV9uAx2F7vSG7ekeY0hNFjs/EpjcS.xbK2MUzVtsnXoytia'),(4,'Bob Slydell','820 Beach Street','bslydell@contoso-noshnow.com','$2y$10$qJRDGkfPnAX/K0GJRYhwh.nNmmx6E50smH2AKk1NZJfQeUAaId8J2'),(5,'Bill Lumbergh','9318 South Pulaski Ave.','blumbergh@contoso-noshnow.com','$2y$10$a5qmSTuPyWasLzEBgku1IOc8H0PEecv0.hCp0QGoBxC3d.PcS.482'),(6,'Barbara Reiss','849 East Depot St.','breiss@contoso-noshnow.com','$2y$10$tyPs1JutdmbAhRes1XV5q.DzdpONuIY/AHMFrh7RvY08V0ePjxw3e'),(7,'Nina McInroe','839 Illinois St.','nmcinroe@contoso-noshnow.com','$2y$10$HzkZz/a48V02TixmACond.e2iI5iUASxw0OTdFZfOZxZ7ExKz9XKW'),(8,'Drew Pitts','234 Depot Ave.','dpitts@contoso-noshnow.com','$2y$10$4P.qqRqjX6N/u1euCIEGpucqn8VxuFxFx9XZCvlSwDin.EXCYKhjW'),(9,'Jennifer Emerson','71 Pierce St.','jemerson@contoso-noshnow.com','$2y$10$G88HHfFk3PR5eIcNCpvy3u5lpWjVB6ZjRd4oSOAkdjcAtg2.im8CK'),(10,'Milton Waddams','497 Thomas Avenue','mwaddams@contoso-noshnow.com','$2y$10$zI/kfwHp1LbFAL.RhPUOR.xCvD2/J/4yY2zr/BtlSTjHHVetbZ0tO'),(11,'Tom Smykowski','25 Manchester Street','tsmykowski@contoso-noshnow.com','$2y$10$NZaG3YCiaPsOPPMXDHO6dedsbngXyfNzh0hD6XDc.A7F7/lpbd9Qm'),(12,'Dom Portwood','905 Deerfield Lane','dportwood@contoso-noshnow.com','$2y$10$MOuRANTltUVrJnGfF9qJcutA73mONYhVIy9XTj0pMr1e6ENZRaSZS');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'contosostore'
--

--
-- Dumping routines for database 'contosostore'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-01-04 16:49:02
