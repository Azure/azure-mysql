<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;

use App\Helpers\AppHelper;
use App\Models\User;
use App\Models\Category;

class ProductController extends Controller
{

	// pages:

	public function categoryList()
	{
		// pretend the user logged in
		$user = AppHelper::instance()->randomUser();

		if (AppHelper::instance()->checkDB() && Schema::hasTable('categories')) {
			$data = Category::orderBy('name')->get();
		} else {
			// if there's no database connection, use a helper and JSON data
			$data = AppHelper::instance()->categoryJson();
			// set a flag so we can display a warning if JSON data is used
			$json_warning = 1;
		}

		// display the floating cart
		$global_cart = AppHelper::instance()->globalCart();

		return view('category-list', ['header'=>1, 'global_cart'=>$global_cart, 'category'=>$data, 'json_warning'=>($json_warning ?? 0)]);
	}

	
	public function itemList($category)
	{
		// pretend the user logged in
		$user = AppHelper::instance()->randomUser();

		if (AppHelper::instance()->checkDB() && Schema::hasTable('categories') && Schema::hasTable('items')) {
			$data = Category::where('url',$category)->with('items')->first();
			$data = $data->items;
		} else {
			// if there's no database connection, use a helper and JSON data
			$data = AppHelper::instance()->itemJson('byCategory',$category);
			// set a flag so we can display a warning if JSON data is used
			$json_warning = 1;
		}

		// display the floating cart
		$global_cart = AppHelper::instance()->globalCart();

		return view('item-list', ['header'=>1, 'global_cart'=>$global_cart, 'item'=>$data, 'json_warning'=>($json_warning ?? 0)]);
	}

}
