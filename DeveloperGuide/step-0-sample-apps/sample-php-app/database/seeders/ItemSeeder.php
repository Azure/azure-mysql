<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

use App\Models\Item;

class ItemSeeder extends Seeder
{
	/**
	 * Run the database seeds.
	 *
	 * @return void
	 */
	public function run()
	{
		// DB::table('items')->truncate();
		Item::query()->delete();
		DB::statement("ALTER TABLE `items` AUTO_INCREMENT = 1");

		$items = [
			// breakfast
			[
				'category_id' => 1,
				'name' => 'Cinnamon Roll',
				'img' => 'cinnamon-rolls-gb12ce8577_1920.jpg',
				'price' => '1.19',
				'cooktime' => 13,
				'desc' => 'Cupcake ipsum dolor sit amet dragée topping topping. Powder cheesecake cake shortbread gummies lollipop jelly carrot cake. Pudding sugar plum carrot cake I love muffin. Dessert topping croissant I love tart soufflé cheesecake sweet sweet. Liquorice pie marshmallow icing topping muffin. Topping brownie oat cake carrot cake donut chocolate bar cake. Bear claw jelly-o ice cream lollipop shortbread dessert jujubes macaroon. I love danish tootsie roll powder candy canes marzipan icing gingerbread chocolate bar.',
			],
			[
				'category_id' => 1,
				'name' => 'Toast & Eggs',
				'img' => 'breakfast-g7a2675ee6_1920.jpg',
				'price' => '2.19',
				'cooktime' => 7,
				'desc' => 'Tiramisu muffin sweet roll cotton candy icing bonbon jelly. Tiramisu oat cake shortbread toffee bonbon shortbread candy canes toffee. Sweet roll biscuit I love oat cake gummies bonbon biscuit danish lemon drops. Toffee ice cream jelly beans caramels muffin. Tart jujubes chocolate bar marshmallow gingerbread I love pie. Chocolate I love chocolate cake cake liquorice lollipop. Tiramisu chocolate jelly-o muffin halvah. Shortbread soufflé ice cream oat cake cotton candy sesame snaps liquorice. Danish marzipan I love jelly brownie muffin halvah candy canes.',
			],
			[
				'category_id' => 1,
				'name' => 'Croissant',
				'img' => 'croissant-ga61b1fb0e_1920.jpg',
				'price' => '3.19',
				'cooktime' => 2,
				'desc' => 'I love chocolate cake I love I love jelly beans cotton candy jelly-o ice cream. Icing cotton candy sweet roll fruitcake biscuit apple pie. Gummies chocolate caramels biscuit I love I love I love cookie croissant. Topping apple pie wafer sesame snaps tootsie roll gummies. Apple pie I love wafer sweet roll tootsie roll. Cheesecake I love apple pie muffin tiramisu lemon drops cake. Macaroon caramels chocolate cotton candy soufflé tart. Chupa chups lemon drops cupcake topping pastry.',
			],
			[
				'category_id' => 1,
				'name' => 'Bacon & Eggs',
				'img' => 'eggs-g9c07e92b1_1920.jpg',
				'price' => '4.19',
				'cooktime' => 14,
				'desc' => 'Toffee sesame snaps chupa chups pie pastry marshmallow I love tootsie roll soufflé. Marshmallow fruitcake cheesecake I love icing cake. Liquorice toffee chocolate bar marzipan cotton candy croissant powder. Bonbon I love danish bear claw tootsie roll. Candy canes wafer fruitcake caramels lollipop tart. Oat cake croissant tart gummi bears cookie muffin. Icing sweet roll chupa chups chupa chups jelly-o brownie. Jelly-o cotton candy liquorice tiramisu halvah jujubes.',
			],
			[
				'category_id' => 1,
				'name' => 'Pancakes',
				'img' => 'pancakes-g9d341228a_1920.jpg',
				'price' => '5.19',
				'cooktime' => 12,
				'desc' => 'Chocolate caramels gingerbread dragée gingerbread brownie powder gummi bears pastry. Sugar plum sugar plum tootsie roll shortbread I love cotton candy. Chocolate cake chocolate bonbon cake biscuit. Toffee cheesecake I love cookie cake marzipan I love chocolate cake liquorice. Biscuit biscuit caramels macaroon lollipop powder tootsie roll. Shortbread jelly-o jujubes jelly-o chocolate carrot cake danish croissant. Biscuit jelly-o donut bonbon muffin carrot cake sesame snaps wafer chupa chups. Chupa chups chocolate bar bonbon I love jelly beans lemon drops macaroon muffin. Chocolate cake cookie jelly-o cake cake croissant muffin halvah candy. Apple pie icing pudding chupa chups macaroon I love biscuit fruitcake I love.',
			],
			[
				'category_id' => 1,
				'name' => 'Biscuits & Gravy',
				'img' => 'biscuits-g07bd069f8_1920.jpg',
				'price' => '6.19',
				'cooktime' => 6,
				'desc' => 'Soufflé marshmallow I love candy canes I love apple pie. Icing wafer I love toffee carrot cake cookie candy canes bear claw pastry. Lollipop topping pudding dessert powder jujubes sesame snaps bonbon apple pie. Macaroon tootsie roll dessert cake I love wafer macaroon sweet roll sesame snaps. Wafer cupcake bear claw sweet brownie I love. Pastry I love muffin marzipan I love topping. Pie candy muffin jelly-o croissant cake sweet. Wafer chocolate lemon drops jujubes lollipop dragée I love jelly. I love macaroon I love powder tootsie roll jelly muffin wafer.',
			],
			// steak
			[
				'category_id' => 2,
				'name' => 'Tomahawk',
				'img' => 'steak-4342500_1920.jpg',
				'price' => '1.29',
				'cooktime' => 27,
				'desc' => 'Bacon ipsum dolor amet shank picanha landjaeger kevin, ham hock spare ribs sausage capicola buffalo alcatra. Short loin spare ribs alcatra bresaola. Salami tongue drumstick tenderloin flank alcatra shank sirloin biltong landjaeger short ribs jerky. Porchetta meatloaf fatback frankfurter bacon tail, ham biltong kielbasa short ribs pork capicola leberkas jowl. Chicken tenderloin kielbasa pork belly, ham hock jowl bacon salami chuck burgdoggen hamburger tongue short loin biltong. Frankfurter sirloin meatloaf ribeye.',
			],
			[
				'category_id' => 2,
				'name' => 'Sirloin',
				'img' => 'steak-1076665_1920.jpg',
				'price' => '2.29',
				'cooktime' => 22,
				'desc' => 'Meatball fatback pastrami, porchetta doner chicken burgdoggen pancetta jerky beef ribs salami. Buffalo ball tip tenderloin chuck, frankfurter alcatra ribeye t-bone spare ribs. Hamburger pork chop swine, picanha flank corned beef burgdoggen shoulder frankfurter ham ball tip. Chicken biltong short ribs short loin spare ribs. Pork loin jerky pork chop, fatback frankfurter filet mignon turducken kevin swine. Prosciutto kielbasa short ribs shoulder frankfurter hamburger. Swine leberkas alcatra jerky, ball tip pastrami meatloaf pork belly doner venison turkey buffalo ham hock pig.',
			],
			[
				'category_id' => 2,
				'name' => 'T-Bone',
				'img' => 'steak-978654_1920.jpg',
				'price' => '3.29',
				'cooktime' => 23,
				'desc' => 'Swine doner leberkas tri-tip pork loin hamburger cupim alcatra spare ribs kielbasa bacon. Shoulder tail alcatra meatloaf beef hamburger, short loin tri-tip cupim ham pork chop. Corned beef kevin strip steak tri-tip. Landjaeger meatball chuck biltong salami fatback jerky pastrami shank beef. Frankfurter ground round strip steak pork chop shoulder, picanha pig doner prosciutto chislic ham. Ham hock alcatra shankle chislic rump landjaeger brisket pork leberkas t-bone meatloaf pancetta pork loin.',
			],
			// pizza
			[
				'category_id' => 3,
				'name' => 'Pepperoni',
				'img' => 'pizza-1344720_1920.jpg',
				'price' => '1.39',
				'cooktime' => 12,
				'desc' => 'Gouda mozzarella babybel. Jarlsberg emmental who moved my cheese cauliflower cheese brie cheesy feet airedale swiss. Port-salut bocconcini monterey jack squirty cheese cut the cheese say cheese cauliflower cheese lancashire. Who moved my cheese who moved my cheese taleggio cheesy feet cheeseburger hard cheese emmental.',
			],
			[
				'category_id' => 3,
				'name' => 'Margherita',
				'img' => 'pizza-3000274_1920.jpg',
				'price' => '2.39',
				'cooktime' => 6,
				'desc' => 'I love cheese, especially who moved my cheese fondue. Parmesan cheese slices the big cheese cheese strings jarlsberg fromage ricotta red leicester. Queso everyone loves cheesecake everyone loves who moved my cheese red leicester fondue smelly cheese. Mozzarella goat blue castello swiss cheese slices hard cheese swiss cow. Cream cheese swiss.',
			],
			// burgers
			[
				'category_id' => 4,
				'name' => 'Sliders',
				'img' => 'hamburger-494706_1920.jpg',
				'price' => '1.49',
				'cooktime' => 9,
				'desc' => 'Ribeye ball tip kevin tri-tip beef biltong. Pastrami pork belly burgdoggen, sirloin bresaola andouille flank fatback short ribs chuck shoulder tongue boudin strip steak. Bacon pancetta biltong kielbasa, cow shank sausage rump chuck spare ribs alcatra ground round meatball chicken strip steak. Sirloin andouille pig ham hock swine kielbasa salami tongue meatball cupim jowl. Cow fatback drumstick picanha ball tip. Meatloaf venison shankle rump, tail tenderloin short ribs.',
			],
			[
				'category_id' => 4,
				'name' => 'Charbroiled',
				'img' => 'hamburger-1238246_1920.jpg',
				'price' => '2.49',
				'cooktime' => 17,
				'desc' => 'Kielbasa boudin alcatra, beef ribs spare ribs rump pork belly pork chop salami ribeye pancetta. Alcatra picanha ground round, frankfurter short loin porchetta leberkas venison cow fatback landjaeger rump boudin. Flank t-bone kielbasa burgdoggen short ribs landjaeger tenderloin ham hock pastrami. Burgdoggen turducken landjaeger, short ribs frankfurter tail brisket chuck shoulder buffalo sausage doner rump. Swine ground round ribeye ham hock tongue turducken sirloin, burgdoggen sausage shank t-bone cupim.',
			],
			[
				'category_id' => 4,
				'name' => 'Diner Burger',
				'img' => 'burger-3442227_1920.jpg',
				'price' => '3.49',
				'cooktime' => 12,
				'desc' => 'Fatback drumstick filet mignon, frankfurter chicken pork meatloaf pork belly venison jerky beef pork loin ham hock biltong. Pork chop ham andouille ground round hamburger. Beef ribs ground round cow pig biltong short ribs sirloin spare ribs. Fatback pork chop cow filet mignon burgdoggen doner picanha swine tongue, tail corned beef meatball pancetta pork.',
			],
			// sushi
			[
				'category_id' => 5,
				'name' => 'Sashimi Fresh Roll',
				'img' => 'sushi-354628_1920.jpg',
				'price' => '1.59',
				'cooktime' => 3,
				'desc' => 'Barbelless catfish eel-goby spiny eel yellowtail snapper mullet minnow white marlin northern pike bigeye? Sauger sandroller; hoki sixgill ray squawfish sailfin silverside. Olive flounder giant danio herring smelt tailor Australasian salmon barbeled houndshark southern grayling porbeagle shark roundhead.',
			],
			[
				'category_id' => 5,
				'name' => 'Power Fish',
				'img' => 'sushi-2853382_1920.jpg',
				'price' => '2.59',
				'cooktime' => 5,
				'desc' => 'Atlantic silverside jewfish shovelnose sturgeon huchen temperate ocean-bass mullet menhaden stargazer yellowtail orangestriped triggerfish bluefin tuna. Arapaima plunderfish arapaima, mudskipper, earthworm eel snubnose eel Pacific viperfish tripletail.',
			],
			[
				'category_id' => 5,
				'name' => 'Spicy Tuna',
				'img' => 'sushi-599721_1920.jpg',
				'price' => '3.59',
				'cooktime' => 7,
				'desc' => 'Elephantnose fish bango longjaw mudsucker; sand stargazer? Dragonet: kissing gourami tench demoiselle; bullhead shark lookdown catfish halibut tubeblenny southern flounder, hairtail gray reef shark. Long-whiskered catfish lake whitefish, worm eel Ratfish European minnow! Javelin temperate perch sandroller waryfish pikehead gouramie longnose dace starry flounder medusafish cusk-eel.',
			],
			[
				'category_id' => 5,
				'name' => 'Avocado Roll',
				'img' => 'maki-716432_1920.jpg',
				'price' => '4.59',
				'cooktime' => 2,
				'desc' => 'Wormfish, glowlight danio Atlantic cod ide flagblenny, ribbon sawtail fish Kafue pike southern grayling. Speckled trout grayling ling nurseryfish threadfin. Snake eel char sturgeon scissor-tail rasbora blue eye worm eel southern smelt. Salmon jellynose fish, buffalofish lanternfish kaluga duckbill eel. Swampfish halosaur flashlight fish wahoo popeye catafula pirarucu; torpedo; rock beauty longnose chimaera elver thornfish, rough scad! Pipefish tompot blenny Kafue pike large-eye bream elasmobranch northern lampfish soapfish rocket danio mudskipper smalltooth sawfish.',
			],
			[
				'category_id' => 5,
				'name' => 'Sampler Plate',
				'img' => 'sushi-2856545_1920.jpg',
				'price' => '5.59',
				'cooktime' => 4,
				'desc' => 'Poolfish waryfish frilled shark louvar, wasp fish blue catfish Molly Miller Black scalyfin gizzard shad, platyfish, common carp. Tiger shark roanoke bass milkfish yellowhead jawfish, round stingray sea bass surfperch treefish Asiatic glassfish. Silver carp scissor-tail rasbora pompano dolphinfish: frogmouth catfish mackerel shark. Perch hardhead catfish sand stargazer: goosefish wolf-herring.',
			],
			[
				'category_id' => 5,
				'name' => 'Veggie Roll',
				'img' => 'sushi-2020287_1920.jpg',
				'price' => '6.59',
				'cooktime' => 2,
				'desc' => 'Stingray, tarpon; clown triggerfish plaice pleco wrasse Pacific herring kuhli loach rough scad, burma danio. River stingray weasel shark popeye catafula Australian grayling remora flying gurnard smalltooth sawfish, dwarf loach pike conger. Thornyhead megamouth shark pencilfish blacktip reef shark Atlantic silverside Black pickerel, electric eel spiderfish bass electric catfish? Peamouth tetra lightfish midshipman monkfish spearfish burrowing goby trahira, collared dogfish yellow weaver driftfish, dorab roosterfish, sea bream.',
			],
			[
				'category_id' => 5,
				'name' => 'Maki',
				'img' => 'sushi-748139_1920.jpg',
				'price' => '7.59',
				'cooktime' => 5,
				'desc' => 'Angler, swampfish orangestriped triggerfish oceanic flyingfish northern anchovy smooth dogfish. Bigscale pomfret stonefish pollyfish warmouth; round herring banded killifish. Walking catfish, weever cod: Antarctic icefish slimy sculpin.',
			],
			// salads
			[
				'category_id' => 6,
				'name' => 'Bowl of Lettuce',
				'img' => 'food-1834645_1920.jpg',
				'price' => '1.69',
				'cooktime' => 1,
				'desc' => 'Carrot grape soko wakame plantain pea broccoli rabe desert raisin. Chard cabbage cress gumbo spinach mung bean turnip greens rock melon chicory collard greens bok choy. Wattle seed wakame eggplant soybean quandong garlic prairie turnip swiss chard radish okra.',
			],
			[
				'category_id' => 6,
				'name' => 'Plate of Lettuce',
				'img' => 'salad-2150548_1920.jpg',
				'price' => '2.69',
				'cooktime' => 1,
				'desc' => 'Nori grape silver beet broccoli kombu beet greens fava bean potato quandong celery. Bunya nuts black-eyed pea prairie turnip leek lentil turnip greens parsnip. Sea lettuce lettuce water chestnut eggplant winter purslane fennel azuki bean earthnut pea sierra leone bologi leek soko chicory celtuce parsley jícama salsify.',
			],
		];
		Item::insert($items);
	}
}
