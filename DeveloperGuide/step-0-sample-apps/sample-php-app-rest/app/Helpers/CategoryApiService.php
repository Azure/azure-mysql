<?php

namespace App\Helpers;

use GuzzleHttp\Client;

class CategoryApiService {
    private Client $client;

    public function __construct()
    {
        $this->client = new Client();
    }

    public static function instance() {
        return new CategoryApiService();
    }

    public function getCategoriesAsc()
    {
        $categoryList = $this->client->request('GET', config('api.category_service_path'));
        return json_decode($categoryList->getBody());
    }
}