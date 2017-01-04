% This script is to get attributes from a tuple <name="", attrib1="", attrib2=""/>

function value = getAttr(item, attrName)

    value = '';
    ndAttr = item.getAttributes;
    for j = 0:ndAttr.getLength-1
        if(strcmp(ndAttr.item(j).getName, attrName) == 1)
            value = ndAttr.item(j).getValue;
        end
    end   
%     assert(length(value) > 0, 'Error: get an attribute failed!');
    
%     value = '';
%     nAttr = size(item.Attributes,2); % get the number of attributes
%     for i = 1:nAttr
%         if(strcmp(item.Attributes(i).Name, attrName) == 1) % if the attribute name matches, get its value
%             value = item.Attributes(i).Value;
%             break;
%         end
%     end
end