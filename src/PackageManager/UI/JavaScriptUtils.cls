Class PackageManager.UI.JavaScriptUtils Extends PackageManager.UI.Screens.Abstract
{

/*
    JAVASCRIPT
*/
/// JavaScript functions used by the whole application
ClassMethod JavaScriptUtilities() As %Status
{
    Set sc = $$$OK
    
    &html<<script type="text/javascript">                       

        /**
        * Converts various iterable types to a plain array
        * Works with: Arrays, Sets, NodeLists, strings, etc.
        */
        function toArray(iterable) {
            // Handle null/undefined
            if (iterable == null) {
                return [];
            }
            
            // Already an array
            if (Array.isArray(iterable)) {
                return iterable.slice(); // Return a copy
            }
            
            // Handle Set
            if (iterable instanceof Set) {
                const result = [];
                iterable.forEach(function(item) {
                    result.push(item);
                });
                return result;
            }
            
            // Handle objects with length property (like NodeList, arguments)
            if (typeof iterable.length === 'number') {
                const result = [];
                for (let i = 0; i < iterable.length; i++) {
                    result.push(iterable[i]);
                }
                return result;
            }
            
            // Handle other iterables (if they have forEach)
            if (typeof iterable.forEach === 'function') {
                const result = [];
                iterable.forEach(function(item) {
                    result.push(item);
                });
                return result;
            }
            
            // Handle strings
            if (typeof iterable === 'string') {
                return iterable.split('');
            }
            
            // Fallback: wrap single item in array
            return [iterable];
        }

        /**
        * Combines multiple iterables into a single array
        * Compatible replacement for: [...iterable1, ...iterable2, ...]
        */
        function combineAll() {
            const result = [];
            for (let i = 0; i < arguments.length; i++) {
                pushAll(result, arguments[i]);
            }
            return result;
        }

        /**
        * Adds all items from an iterable to an existing array
        * Compatible replacement for: targetArray.push(...iterable)
        */
        function pushAll(targetArray, iterable) {
            const items = toArray(iterable);
            for (let i = 0; i < items.length; i++) {
                targetArray.push(items[i]);
            }
            return targetArray;
        }

        // Utility to remove an item from a Set and return a new Set
        // Ensure compatibility with ObjectScript environments, where delete operator may not work
        function removeFromSet(set, item) {
            const newArray = [];
            set.forEach(function(value) {
                if (value !== item) {
                    newArray.push(value);
                }
            });
            return new Set(newArray);
        }


    </script>>
    Return sc
}

}
