<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;

use App\Helpers\AppHelper;
use App\Models\User;

class HomeController extends Controller
{

	/*
		Using the default Laravel 8 installation, this app example attempts to cover the very basic 
		essentials without getting too complex. We've provided sample JSON data so the app can function 
		even if there is no database connection. (JSON data can be found in /app/Helpers/AppHelper.php)
	*/

	// pages:
	
	public function index()
	{
		// forget the user session so we can get a new user on reload
		session()->forget('user');

		// pretend the user logged in
		$user = AppHelper::instance()->randomUser();
		$json_warning = $user->fromJson;

		// display the floating cart
		$global_cart = AppHelper::instance()->globalCart();

		return view('index', ['global_cart'=>$global_cart, 'user'=>$user, 'json_warning'=>($json_warning ?? 0)]);
	}

}
