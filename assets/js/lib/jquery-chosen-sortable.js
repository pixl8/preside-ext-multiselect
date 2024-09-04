/*
 * Author: Yves Van Broekhoven & Simon Menke
 * Created at: 2012-07-05
 *
 * Fork: Andy Thomas (http://and.yt)
 * Fork Created at: 2014-08-04
 * Fork URL: https://github.com/antom/jquery-chosen-sortable
 *
 * Requirements:
 * - jQuery
 * - jQuery UI
 * - Chosen
 *
 * Version: 1.0.1
 */

/*
 * Customised by Pixl8 - Nick to accomodate sort order of default selected options
 */
(function($) {
  $.fn.chosenClassPrefix = function() {
    return $(this).is('[class^="chzn-"]')
      ? 'chzn'
      : 'chosen';
  };

  $.fn.chosenOrder = function() {
    var $this   = this.filter('.' + this.chosenClassPrefix() + '-sortable[multiple]').first(),
        $chosen = $this.siblings('.' + this.chosenClassPrefix() + '-container');

    return $($chosen.find('.' + this.chosenClassPrefix() + '-choices li[class!="search-field"]').map( function() {
      if (!this) {
        return undefined;
      }
      return $this.find('option:contains(' + $(this).text() + ')')[0];
    }));
  };


  /*
   * Extend jQuery
   */
  $.fn.chosenSortable = function() {
    var $this = this.filter('.' + this.chosenClassPrefix() + '-sortable[multiple]');

    $this.each(function(){
      var $select = $(this);
      var $chosen = $select.siblings('.' + $select.chosenClassPrefix() + '-container');

      if ($.ui) {
        // On mousedown of choice element,
        // we don't want to display the dropdown list
        $chosen.find('.' + $select.chosenClassPrefix() + '-choices').bind('mousedown', function(event){
          if ($(event.target).is('span')) {
            event.stopPropagation();
          }
        });

        var $choicesContainer = $chosen.find('.' + $select.chosenClassPrefix() + '-choices');

        // Reorder selected choices by default value
		var indexOrder = $select.attr( "data-index-order" ) || "";
		if( indexOrder.length ) {
			indexOrder = indexOrder.split( "," );
			indexOrder.reverse();
			for( var i in indexOrder ) {
				$choicesContainer.prepend( $choicesContainer.find( ".search-choice [data-option-array-index='" + ( indexOrder[i] - 1 ) + "']" ).parent() );
			}
		}

        // Initialize jQuery UI Sortable
        $choicesContainer.sortable({
          placeholder: 'search-choice-placeholder',
          items: 'li:not(.search-field)',
          tolerance: 'pointer',
          start: function(e,ui) {
            ui.placeholder.width(ui.item.outerWidth());
            ui.placeholder.height(ui.item.outerHeight());
          }
        });

        // Intercept form submit & order the chosens
        if ($select.closest('form')) {
          $select.closest('form').bind('submit', function(){
		  	var hasSiblings = $select.filter('.' + $select.chosenClassPrefix() + '-sortable[multiple]').first().siblings( '.' + $select.chosenClassPrefix() + '-container' ).length > 0
			if ( hasSiblings ) {
				var $options = $select.chosenOrder();
				$select.children().remove();
				$select.append($options);
			}
          });
        }
      } else {
        console.error('jquery-chosen-sortable requires JQuery UI to have been initialised.');
      }

    });

  };

}(jQuery));