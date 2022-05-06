@extends('layouts.app')
@section('content')

	<div class="hero">
		<div class="logo">{{ config('app.name', 'Contoso NoshNow') }}</div>
	</div>

	<div class="center-block order-form">
		<div class="one-half column">
			<form>
				<label for="delivery_address">Welcome back, <span class="blue">{{ $user->name }}</span>! Where should we deliver your meal?</label>
				<!-- 
					Keeping it simple for demo purposes, only displaying a single street address field. We don't
					actually use this field for anything though. It's just for show!
				 -->
				<input id="delivery_address" class="u-full-width" type="text" placeholder="Enter your street address" value="{{ $user->address }}">
				<a href="{{ route('category-list') }}" class="start-order button button-primary">Start Order</a>
			</form>
		</div>
	</div>

@endsection
@push('scripts')
<script>
</script>
@endpush
