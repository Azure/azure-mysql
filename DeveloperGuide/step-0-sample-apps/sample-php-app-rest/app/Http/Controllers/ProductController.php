<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;

use App\Helpers\AppHelper;
use App\Helpers\CategoryApiService;
use App\Models\User;
use App\Models\Category;
use GuzzleHttp\Exception\RequestException;

use App\Helpers\ItemApiService;

class ProductController extends Controller
{

	// pages:

	public function categoryList()
	{
		// pretend the user logged in
		$user = AppHelper::instance()->randomUser();

		try
		{
			$data = CategoryApiService::instance()->getCategoriesAsc();
		}
		catch (RequestException $e)
		{
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

		try
		{
			$data = ItemApiService::instance()->getItemsAsc($category);
		}
		catch (RequestException $e)
		{
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
