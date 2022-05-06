<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/


// pages:

Route::get('/', 'HomeController@index')->name('home');

Route::get('/category-list', 'ProductController@categoryList')->name('category-list');
Route::get('/item-list/{category}', 'ProductController@itemList')->name('item-list');

Route::get('/checkout', 'CartController@checkout')->name('checkout');
Route::post('/process-order', 'CartController@processOrder')->name('process-order');
Route::get('/receipt', 'CartController@receipt')->name('receipt');


// ajax:

Route::post('/add-to-cart', 'CartController@addToCart');
Route::post('/update-cart', 'CartController@updateCart');
