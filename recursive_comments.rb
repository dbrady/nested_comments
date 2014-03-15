# require "./do_not_peek_behind_the_curtain/bad_code"

Comment  = Struct.new(:id, :parent_id, :nesting) do
  def depth
    nesting.split(".").size
  end
end

comments = [
            [1,  nil, "0001"],
            [2,  nil, "0002"],
            [3,  2,   "0002.0001"],
            [4,  nil, "0003"],
            [5,  3,   "0003.0001"],
            [6,  3,   "0003.0002"],
            [7,  nil, "0004"],
            [8,  nil, "0005"],
            [9,  8,   "0005.0001"],
            [10, 9,   "0005.0001.0001"],
            [11, 8,   "0005.0002"],
            [12, 8,   "0005.0005"],
            [13, 8,   "0005.0006"],
           ].map { |args| Comment.new(*args) }

# --- show expected results:
# >> <ul>
# >>   <li>0001</li>
# >>   <li>0002
# >>     <ul>
# >>       <li>0002.0001</li>
# >>     </ul>
# >>   </li>
# >>   <li>0003
# >>     <ul>
# >>       <li>0003.0001</li>
# >>       <li>0003.0002</li>
# >>     </ul>
# >>   </li>
# >>   <li>0004</li>
# >>   <li>0005
# >>     <ul>
# >>       <li>0005.0001
# >>         <ul>
# >>           <li>0005.0001.0001</li>
# >>         </ul>
# >>       </li>
# >>       <li>0005.0002</li>
# >>       <li>0005.0005</li>
# >>       <li>0005.0006</li>
# >>     </ul>
# >>   </li>
# >> </ul>

class RecursiveCode
  def tab(gutter, depth)
    '  ' * (gutter + depth)
  end

  def render_list(comments, gutter=0, depth=0)
    indent = tab(gutter, depth)
    puts indent + "<ul>"
    render_items(comments, gutter, depth+1)
    puts indent + "</ul>"
  end

  def next_item_is_out_of_my_depth?(comments, depth)
    comments.empty? || comments.first.depth < depth
  end

  def render_only_child(item, gutter, depth)
    indent = tab(gutter, depth)
    puts indent + "<li>#{item.nesting}</li>"
  end

  def render_middle_child(item, comments, gutter, depth)
    indent = tab(gutter, depth)
    puts indent + "<li>#{item.nesting}"
    render_list(comments, gutter+1, depth)
    puts indent + "</li>"
  end

  def next_item_is_even_deeper?(comments, depth)
    !comments.empty? && comments.first.depth > depth
  end

  def render_items(comments, gutter, depth)
    indent = tab(gutter, depth)
    until next_item_is_out_of_my_depth?(comments, depth)
      item = comments.shift
      if next_item_is_even_deeper?(comments, depth)
        render_middle_child(item, comments, gutter, depth)
      else
        render_only_child(item, gutter, depth)
      end
    end
  end

  def self.show_expected_results(comments)
    new.render_list(comments)
  end
end


RecursiveCode.show_expected_results comments
