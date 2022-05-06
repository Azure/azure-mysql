@extends('layouts.app')
@section('content')

	<h3>Receipt</h3>

	<div class="center-block item-list">
	<p>Thank you for placing your food order with {{ config('app.name', '') }}!</p>
	<p id="remaining_text"></p>

	<a href="{{ route('category-list') }}" class="button">Start a New Order</a>
	</div>

@endsection
@push('scripts')
<script>
$(document).ready( function() {
	set_receipt_text('{{ $time_left ?? '0' }}');
});
</script>
@endpush
