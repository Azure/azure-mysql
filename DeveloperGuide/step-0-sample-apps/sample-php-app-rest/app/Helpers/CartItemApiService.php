<?php

namespace App\Helpers;

use GuzzleHttp\Client;

class CartItemApiService {
    private Client $client;

    public function __construct()
    {
        $this->client = new Client();
    }

    public static function instance() {
        return new CartItemApiService();
    }

    public function addCartItems($cartItems)
    {
        $this->client->request('POST', config('api.cart_item_service_path'), ['json' => $cartItems]);
    }
}