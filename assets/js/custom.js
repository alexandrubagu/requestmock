$(document).ready(function() {
    var control = $('.control').data('value');

    $(document).on('click', '.add-header', function(e) {
        var $input_group_prev = $(e.target).closest('div');
        var $input_group_next = $input_group_prev.clone();
        $input_group_prev.find('.remove-header').removeClass('hidden');
        $input_group_prev.find('.add-header').addClass('hidden');
        $input_group_next.find('input').val('');
        $input_group_prev.parent().append($input_group_next);
    });

    $(document).on('click', '.remove-header', function(e) {
        $(e.target).closest('div').remove();
    });

    $('.js-switch').each(function(index, value) {
        var switchery = new Switchery(value, { size: 'small' });
        $(switchery.switcher).on('click', function(e) {
            $.ajax({
                url: "/switch",
                type: "POST",
                beforeSend: function(xhr) {
                    xhr.setRequestHeader("x-csrf-token", control);
                },
                data: {
                    "state": switchery.isChecked(),
                    "mock": $(value).data('mock')
                }
            });
        });
    });

    $('[data-toggle="tooltip"]').tooltip({
        selector: true,
        title: function() {
            return $(this).attr('title');
        }
    });

    $(document).on('click', 'a[data-action=delete]', function(e) {
        e.preventDefault();
        var $element = $(this);
        var mock = $(this).attr('data-mock');
        if (mock) {
            $.ajax({
                url: "/delete",
                type: "POST",
                beforeSend: function(xhr) {
                    xhr.setRequestHeader("x-csrf-token", control);
                },
                data: { "mock": mock },
                success: function(result) {
                    $.toast({
                        heading: 'Success',
                        text: 'Mock was deleted',
                        position: 'top-right',
                        loaderBg: '#ff7676',
                        // icon: 'error',
                        hideAfter: 3500,
                        stack: 6
                    });
                    $element.closest('tr').remove();
                },
                error: function() {
                    $.toast({
                        heading: 'Error',
                        heading: "Can't delete mock. Please try again later.",
                        position: 'top-right',
                        loaderBg: '#ff6849',
                        icon: 'error',
                        hideAfter: 3500
                    });
                }
            });
        }
    });

    $(document).on('click', '.modal-request', function(e) {
        var modal = $(e.target).siblings('.modal');
        $(modal).modal('show');
    });
});