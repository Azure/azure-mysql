<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;

use App\Helpers\AppHelper;
use App\Helpers\ItemApiService;
use App\Helpers\CartApiService;
use App\Helpers\CartItemApiService;
use App\Helpers\OrderApiService;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Order;
use App\Models\Item;
use GuzzleHttp\Exception\RequestException;

class CartController extends Controller
{

	// pages:

	public function checkout()
	{
		$user = session('user');
		$cart = session('cart');
		$item_list = [];
		if ($cart) $item_list = array_keys($cart);
		try
		{
			$items = ItemApiService::instance()->getItemsInCart($item_list);
		}
		catch (RequestException $e)
		{
			// if there's no database connection, use a helper and JSON data
			$items = AppHelper::instance()->itemJson('items',$item_list);
			// set a flag so we can display a warning if JSON data is used
			$json_warning = 1;
		}
		$cart_total = 0;
		$cart_data = [];
		foreach($items as $item) {
			$qty = $cart[$item->id];
			$item->qty = $qty;
			// set price to 0 in the event there is bad data
			$price = is_numeric($item->price) ? $item->price : 0;
			// set item subtotal
			$item->sub = $qty * number_format($price, 2);
			// increment cart total
			$cart_total += $item->sub;
			// add item to cart array
			$cart_data[$item->id] = $item;
		}

		try
		{
			$cart = CartApiService::instance()->openCart($user->id);

			// Batch cart items and then save them using the API
			$cartItems = [];
			foreach($cart_data as $id => $item) {
				array_push($cartItems, array('cartId' => $cart->id, 'itemId' => $id, 'qty' => $item->qty));
			}
			CartItemApiService::instance()->addCartItems($cartItems);

			session(['cart_id' => $cart->id]);
		}
		catch (RequestException $e)
		{
			session(['cart_id' => 'session']);
			$json_warning = 1;
		}

		return view('checkout', ['header'=>1, 'user'=>$user, 'cart_data'=>$cart_data, 'cart_total'=>$cart_total, 'json_warning'=>($json_warning ?? 0)]);
	}


	public function processOrder(Request $request)
	{
		$user = session('user');
		$cart = session('cart');
		$cart_id = session('cart_id');

		if (!$user || !$cart || !$cart_id) {
			// something is missing, bounce back to the checkout page
			return redirect()->route('checkout');
		}

		if ($cart) {
			$item_list = array_keys($cart);

			try
			{
				$item = ItemApiService::instance()->getItemsInCart($item_list);
			}
			catch (RequestException $e)
			{
				$item = AppHelper::instance()->itemJson('items',$item_list,'cooktime');
			}

			// show a semi-random delivery time to make it more fun
			$cooktime = 0;
			// start with a random prep/drive time
			$time = rand(5,20);
			foreach($item as $i) {
				// get the longest cooktime of all items in the cart
				if ($cooktime < $i->cooktime) { 
					$cooktime = $i->cooktime; 
				}
			}
			// add the cooktime to the random prep/drive time
			$time+=$cooktime;
			// turn it into minutes from *right now*
			$delivery = strtotime(now())+($time*60);

			$name = $request->name ?? $user->name;
			$address = $request->address ?? $user->address;

			try
			{
				CartApiService::instance()->closeCart($cart_id);
				OrderApiService::instance()->createOrder($user->id, $cart_id, $name, $address, $request->special_instructions, $time);
			}
			catch (RequestException $e) {}

			// clear all the sessions
			session()->forget('cart');
			session()->forget('cart_id');
			session()->forget('receipt');

			session([ 'receipt' => ['created_at'=>strtotime(now()), 'delivery'=>$delivery] ]);
		}		
		// redirect to the receipt page
		return redirect()->route('receipt');
	}


	public function receipt()
	{
		$time_left = 0;

		// use the receipt session or display a generic message
		$receipt = session('receipt');
		if ($receipt) {
			// figure out how many minutes are left before food arrives
			$time_left = floor( ($receipt['delivery'] - strtotime(now()) )/60 );
		}

		return view('receipt', ['header'=>1, 'receipt'=>$receipt, 'time_left'=>$time_left]);
	}



	// ajax:

	public function addToCart(Request $request)
	{
		// Item ID
		$id = $request->item;
		if (!session('cart')) {
			session([ 'cart' => [] ]);
		}
		$cart = session('cart');
		if (isset($cart[$id])) {
			$cart[$id]++;
		} else {
			$cart[$id] = 1;
		}
		session(['cart' => $cart]);

		// update the floating cart
		$global_cart = AppHelper::instance()->globalCart();

		return $global_cart;
	}

	public function updateCart(Request $request)
	{
		$item = $request->cart_items;
		$cart = session('cart');
		foreach ($item as $id => $qty) {
			if (isset($cart[$id]) && $qty<1) {
				unset($cart[$id]);
			} else {
				$cart[$id] = $qty;
			}
		}
		session(['cart' => $cart]);

		// update the floating cart
		$global_cart = AppHelper::instance()->globalCart('show');

		return $global_cart;
	}

}
