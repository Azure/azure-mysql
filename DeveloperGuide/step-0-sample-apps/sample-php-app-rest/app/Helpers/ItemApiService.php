<?php

namespace App\Helpers;

use GuzzleHttp\Client;

class ItemApiService {
    private Client $client;

    public function __construct()
    {
        $this->client = new Client();
    }

    public static function instance() {
        return new ItemApiService();
    }

    public function getItemsAsc($url)
    {
        $categoryList = $this->client->request('GET', config('api.item_service_path') . '/categories/' . $url);
        return json_decode($categoryList->getBody());
    }

    public function getItemsInCart($cartItems)
    {
        $body = array("itemKeys" => $cartItems);
        $itemList = $this->client->request('GET', config('api.item_service_path'), ['json' => $body]);
        return json_decode($itemList->getBody());
    }
}