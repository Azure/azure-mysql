<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;

use App\Helpers\AppHelper;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Order;
use App\Models\Item;

class CartController extends Controller
{

	// pages:

	public function checkout()
	{
		$user = session('user');
		$cart = session('cart');
		$item_list = [];
		if ($cart) $item_list = array_keys($cart);
		if (AppHelper::instance()->checkDB() && Schema::hasTable('items') && Schema::hasTable('carts')) {
			$items = Item::whereIn('id',$item_list)->orderBy('name')->get();
		} else {
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

		if (AppHelper::instance()->checkDB() && Schema::hasTable('carts')) {
			$full_cart = Cart::updateOrCreate(
				['user_id' => $user->id, 'status' => 'open'],
			);
			$full_cart->save();
			foreach($cart_data as $id => $item) {
				$cart_insert = CartItem::updateOrCreate(
					['cart_id' => $full_cart->id, 'item_id' => $id],
					['qty' => $item->qty]
				);
				$full_cart->cart_items()->save($cart_insert);
			}
			session(['cart_id' => $full_cart->id]);
		} else {
			// if there's no database connection, fake it with sessions
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
			if (AppHelper::instance()->checkDB() && Schema::hasTable('items') && Schema::hasTable('carts')) {
				$item = Item::whereIn('id',$item_list)->orderBy('name')->get();
			} else {
				// if there's no database connection, use a helper and JSON data
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

			if (AppHelper::instance()->checkDB() && Schema::hasTable('carts') && $cart_id!='session') {
				// update cart to 'closed'
				Cart::where('id', $cart_id)->update(['status' => 'closed']);
				// save to order table
				$order = new Order([
					'user_id' => $user->id,
					'cart_id' => $cart_id,
					'name' => $name,
					'address' => $address,
					'special_instructions' => $request->special_instructions,
					'cooktime' => $time
				]);
				$order->save();
			}

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
