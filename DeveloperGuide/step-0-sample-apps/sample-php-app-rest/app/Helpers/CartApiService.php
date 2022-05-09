<?php

namespace App\Helpers;

use GuzzleHttp\Client;

class CartApiService {
    private Client $client;

    public function __construct()
    {
        $this->client = new Client();
    }

    public static function instance() {
        return new CartApiService();
    }

    public function openCart($userId) {
        $body = array("userId" => $userId);
        $cart = $this->client->request('POST', config('api.cart_service_path'), [ 'json' => $body ]);
        return json_decode($cart->getBody());
    }

    public function closeCart($cartId) {
        $cart = $this->client->request('PUT', config('api.cart_service_path') . '/' . strval($cartId));
        return json_decode($cart->getBody());
    }

}