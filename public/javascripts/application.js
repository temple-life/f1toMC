function find_people(frm) {
	return false;
}

//
// Automatically calls all functions in APP.init
//
jQuery(document).ready(function() {
	APP.go();
});

var APP = (function($, window, undefined) {
	// Global AJAX settings.
	$.ajaxSetup({
		dataType: 'html',
		'beforeSend': function(xhr) {
			xhr.setRequestHeader('Accept', 'text/javascript');
		}
	});

	// Expose contents of APP.
	return {
		go: function() {
			for (var i in APP.init) {
				APP.init[i]();
			}
		},
		init: {
			full_input_size: function() {
				if (!$('textarea, .input_full').length) {
					return;
				}

				// This fixes width: 100% on <textarea> and class="input_full".
				// It ensures that form elements don't go wider than container.
				$('textarea, .input_full').wrap('<span class="input_full_wrap"></span>');
			},
			ie_skin_inputs: function() {
				// Test for Internet Explorer 6.
				if ((typeof document.addEventListener === 'function' && window.XMLHttpRequest) || !$(':input').length) {
					return;
				}

				var type_regex = /date|datetime|datetime\-local|email|month|number|password|range|search|tel|text|time|url|week/;

				$(':input').each(function() {
					var el = $(this);

					if (this.multiple && this.tagName.toLowerCase() === 'select') {
						el.addClass('ie_multiple');
					}
					else if (this.type === 'button' || this.type === 'submit' || this.type === 'reset') {
						el.addClass('ie_button');
					}
					else if (this.type.match(type_regex)) {
						el.addClass('ie_text');
					}
				});
			},
			dashboard: function() {
				if (!$('div.equalize_1').length) {
					return;
				}

				var equalize_1 = $('div.equalize_1');

				APP.misc.equalize(equalize_1);
			},
			remove_row: function() {
				if (!$('a.remove').length) {
					return;
				}

				function enable_or_disable_form(el) {
					var num_hidden = el.closest('form').find('table.grid input:hidden').length;
					var num_disabled = el.closest('form').find('table.grid input:hidden:disabled').length;
					var this_form = el.closest('form')[0];
					var submit_button = this_form.find('input:submit');

					if (num_hidden === num_disabled) {
						submit_button.attr('disabled', 'disabled');
						this_form.onsubmit = function() {
							return false;
						};
					}
					else {
						submit_button.removeAttr('disabled');
						this_form.onsubmit = function() {
							return true;
						};
					}
				}

				$('table.grid a.remove').live('mousedown', function() {
					var el = $(this);
					var tr = el.closest('tr');
					var flag = el.closest('tr').find('input:hidden');

					if (tr.hasClass('row_inactive')) {
						tr.removeClass('row_inactive');
						el.text('Remove').removeClass('remove_alt');
						flag.removeAttr('disabled');
					}
					else {
						tr.addClass('row_inactive');
						el.text('Undo').addClass('remove_alt');
						flag.attr('disabled', 'disabled');
					}

					enable_or_disable_form(el);

					return false;
				}).live('click', function() {
					return false;
				});
			},
			check_all: function() {
				if (!$('a.check_all').length) {
					return;
				}

				function enable_or_disable_form(el) {
					var table = el.closest('table.grid');
					var num_checked = table.find('input:checkbox:checked').length;
					var this_form = el.closest('form')[0];
					var submit_button = this_form.find('input:submit');

					if (!num_checked) {
						submit_button.attr('disabled', 'disabled');
						this_form.onsubmit = function() {
							return false;
						};
					}
					else {
						submit_button.removeAttr('disabled');
						this_form.onsubmit = function() {
							return true;
						};
					}
				}

				$('a.check_all').each(function() {
					var el = $(this);
					enable_or_disable_form(el);
				}).click(function() {
					var el = $(this);
					var checkboxes = el.closest('table').find('tr td:first-child input:checkbox');
					var checked = el.closest('table').find('tr td:first-child input:checkbox:checked');

					if (checkboxes.length === checked.length) {
						checkboxes.removeAttr('checked');
					}
					else {
						checkboxes.attr('checked', 'checked');
					}

					enable_or_disable_form(el);

					return false;
				});

				$('table.grid input:checkbox').live('click', function() {
					var el = $(this);
					enable_or_disable_form(el);
				});
			},
			jump_list: function() {
				if (!$('select.jump_list').length) {
					return;
				}

				$('select.jump_list').change(function() {
					if (this.value) {
						var url = window.location.toString();
						var url_len = url.length;
						var last_char = url.substring(url_len - 1, url_len);

						if (last_char === '/') {
							window.top.location = url + this.value;
						}
						else {
							window.top.location = url + '/' + this.value;
						}
					}
				});
			},
			tooltip: function() {
				// Does element exist?
				if (!$('*[title]').length) {
					// If not, exit.
					return;
				}

				// Insert tooltip (hidden).
				$('body').append('<div id="tooltip"><div id="tooltip_inner"></div></div>');

				// Empty variables.
				var tt_title, tt_alt;

				var tt = $('#tooltip');
				var tt_i = $('#tooltip_inner');

				// Watch for hover.
				$('*[title]').hover(function() {
					// Store title, empty it.
					if ($(this).attr('title')) {
						tt_title = $(this).attr('title');
						$(this).attr('title', '');
					}

					// Store alt, empty it.
					if ($(this).attr('alt')) {
						tt_alt = $(this).attr('alt');
						$(this).attr('alt', '');
					}

					// Insert text.
					tt_i.html(tt_title);

					// Show tooltip.
					tt.show();
				},
				function() {
					// Hide tooltip.
					tt.hide();

					// Empty text.
					tt_i.html('');

					// Fix title.
					if (tt_title) {
						$(this).attr('title', tt_title);
					}

					// Fix alt.
					if (tt_alt) {
						$(this).attr('alt', tt_alt);
					}

				// Watch for movement.
				}).mousemove(function(ev) {
					// Event coordinates.
					var ev_x = ev.pageX;
					var ev_y = ev.pageY;

					// Tooltip coordinates.
					var tt_x = tt.outerWidth();
					var tt_y = tt.outerHeight();

					// Body coordinates.
					var bd_x = $('body').outerWidth();
					var bd_y = $('body').outerHeight();

					// Move tooltip.
					tt.css({
						'top': ev_y + tt_y > bd_y ? ev_y - tt_y : ev_y,
						'left': ev_x + tt_x + 20 > bd_x ? ev_x - tt_x - 10 : ev_x + 15
					});
				});
			}
		},
		misc: {
			equalize: function(jq_arr, min_height) {
			    var tallest = min_height || 0;

				jq_arr.each(function() {
					var this_height = $(this).height();

					if (this_height > tallest) {
						tallest = this_height;
					}
				}).css({
					height: tallest
				});
			}
		},
		sync: {
			get_attributes: function(url, id) {
				if (!$('#btn_find_people, #person_attribute').length) {
					return;
				}

				if (id.length > 0) {
					$.get(url, {attribute_group_id: id}, function(data) {
						$('#person_attribute').find('option').remove().end().append(data);
						document.getElementById('btn_find_people').disabled = ($('#person_attribute').val().length === 0);
					});
				}
				else {
					$('#person_attribute').find('option').remove().end().append('<option>--</option>');
					document.getElementById('btn_find_people').disabled = true;
				}
			}
		}
	};
// Pass in jQuery ref.
})(jQuery, this);