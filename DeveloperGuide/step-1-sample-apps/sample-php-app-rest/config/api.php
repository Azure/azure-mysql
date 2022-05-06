<?php

return [
    'cart_service_path' => getenv('REST_API_BASE_PATH') . '/carts',
    'user_service_path' => getenv('REST_API_BASE_PATH') . '/users',
    'cart_item_service_path' => getenv('REST_API_BASE_PATH') . '/cartitems',
    'category_service_path' => getenv('REST_API_BASE_PATH') . '/categories',
    'item_service_path' => getenv('REST_API_BASE_PATH') . '/items',
    'order_service_path' => getenv('REST_API_BASE_PATH') . '/orders'
];
