<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Cart extends Model
{
	use HasFactory;

	public $timestamps = false;

	protected $fillable = [
		'user_id',
		'status',
	];

	protected $with = [
		'cart_items',
	];

	public function cart_items()
	{
		return $this->hasMany(CartItem::class, 'cart_id', 'id');
	}

}
