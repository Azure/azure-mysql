<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
	use HasFactory;

	protected $fillable = [
		'user_id',
		'cart_id',
		'name',
		'address',
		'special_instructions',
		'cooktime',
	];

	protected $with = [
		'cart',
	];

	public function cart()
	{
		return $this->hasOne(Cart::class, 'cart_id', 'id');
	}

}
