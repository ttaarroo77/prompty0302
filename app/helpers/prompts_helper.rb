module PromptsHelper
  def truncate_title(title)
    if title.length > 15
      title[0..14] + '...'
    else
      title
    end
  end
end
