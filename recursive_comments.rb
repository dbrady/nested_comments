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
  attr_reader :comments, :gutter, :depth

  def initialize(comments, gutter=0, depth=0)
    @comments, @gutter, @depth = comments, gutter, depth
  end

  def indent
    '  ' * (gutter + depth)
  end

  def render_list
    puts indent + "<ul>"
    RecursiveCode.new(comments, gutter, depth+1).render_items
    puts indent + "</ul>"
  end

  def render_only_child(item)
    puts indent + "<li>#{item.nesting}</li>"
  end

  def render_middle_child(item)
    puts indent + "<li>#{item.nesting}"
    RecursiveCode.new(comments, gutter+1, depth).render_list
    puts indent + "</li>"
  end

  def next_item_is_out_of_my_depth?
    comments.empty? || comments.first.depth < depth
  end

  def next_item_is_even_deeper?
    !comments.empty? && comments.first.depth > depth
  end

  def render_items
    until next_item_is_out_of_my_depth?
      item = comments.shift
      if next_item_is_even_deeper?
        render_middle_child item
      else
        render_only_child item
      end
    end
  end

  def render
    render_list
  end
end

recurser = RecursiveCode.new(comments).render
#recurser.show_expected_results

