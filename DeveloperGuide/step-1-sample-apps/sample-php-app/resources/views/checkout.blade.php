@extends('layouts.app')
@section('content')

	<h3>Checkout</h3>

	<div class="center-block item-list">
		<div class="two-thirds column">
			@if ($cart_data)
			<table class="u-full-width m-b-0 checkout-cart">
				<tbody>
				@foreach($cart_data as $c)
					<tr>
						<td><div class="image" style="background-image:url(/img/{{ $c->img }});"></div></td>
						<td>
							<span>{{ $c->name }}</span>
							<span>{{ $c->qty }} @ {{ is_numeric($c->price) ? number_format($c->price, 2) : '0.00' }}</span>
						</td>
						<td>{{ number_format($c->sub, 2) }}</td>
					</tr>
				@endforeach
					<tr>
						<td colspan="2">Total:</td>
						<td>$ {{ number_format($cart_total, 2) }}</td>
					</tr>
				</tbody>
			</table>
		</div>
		<div class="one-half column">
			<form method="post" action="{{ route('process-order') }}">
				{{ csrf_field() }}

				<!-- keeping it simple for demo purposes, only displaying a few fields -->
				<label for="name" class="text-left">Name</label>
				<input id="name" name="name" type="text" class="u-full-width" value="{{ $user ?? '' ? $user->name : '' }}">
				<label for="address" class="text-left">Address</label>
				<input id="address" name="address" type="text" class="u-full-width" value="{{ $user ?? '' ? $user->address : '' }}">
				<label for="special_instruction" class="text-left">Special Instructions</label>
				<textarea id="special_instruction" name="special_instructions" class="u-full-width"></textarea>

				<a href="{{ route('category-list') }}" class="button">Add to Order</a>
				<button class="button button-primary complete-order">Complete Order</button>
			</form>
			@else
			<p>You have no food in your cart.</p>
			<a href="{{ route('category-list') }}" class="button">Start a New Order</a>
			@endif
		</div>
	</div>

@endsection
@push('scripts')
<script>
</script>
@endpush
