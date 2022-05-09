<?php

namespace App\Helpers;

use GuzzleHttp\Client;

class OrderApiService {
    private Client $client;

    public function __construct()
    {
        $this->client = new Client();
    }

    public static function instance() {
        return new OrderApiService();
    }

    public function createOrder($userId, $cartId, $name, $address, $specialInstructions, $cookTime) {
        $body = array(
            'userId' => $userId,
            'cartId' => $cartId,
            'name' => $name,
            'address' => $address,
            'specialInstructions' => $specialInstructions,
            'cooktime' => $cookTime
        );
        $order = $this->client->request('POST', config('api.order_service_path'), ['json' => $body]);
        return json_decode($order->getBody());
    }

}