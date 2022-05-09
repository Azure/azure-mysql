<?php

namespace App\Helpers;

use GuzzleHttp\Client;

class UserApiService {
    private Client $client;

    public function __construct()
    {
        $this->client = new Client();
    }
    
    public static function instance()
    {
        return new UserApiService();
    }

    public function getRandomUser()
    {
        $res = $this->client->request('GET', config('api.user_service_path') . '/randomUser');
        return json_decode($res->getBody());
    }
}
