<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

use App\Models\Category;

class CategorySeeder extends Seeder
{
	/**
	 * Run the database seeds.
	 *
	 * @return void
	 */
	public function run()
	{
		// DB::table('categories')->truncate();
		Category::query()->delete();
		DB::statement("ALTER TABLE `categories` AUTO_INCREMENT = 1");

		$categories = [
			[
				'name' => 'Breakfast',
				'url' => 'breakfast',
				'img' => 'potatoes-g792cf4128_1920.jpg',
			],
			[
				'name' => 'Steak',
				'url' => 'steak',
				'img' => 'tomahawk-ge5ea2413d_1920.jpg',
			],
			[
				'name' => 'Pizza',
				'url' => 'pizza',
				'img' => 'pizza-g204a8b3d6_1920.jpg',
			],
			[
				'name' => 'Burgers',
				'url' => 'burgers',
				'img' => 'hamburger-g685f013b8_1920.jpg',
			],
			[
				'name' => 'Sushi',
				'url' => 'sushi',
				'img' => 'food-g3eb975adc_1920.jpg',
			],
			[
				'name' => 'Salads',
				'url' => 'salads',
				'img' => 'salad-g3f02f56a0_1920.jpg',
			],
		];
		Category::insert($categories);
	}
}
