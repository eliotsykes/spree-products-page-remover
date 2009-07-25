# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'

class ProductsPageRemoverExtension < Spree::Extension
  version "1.0"
  description "Extension for removing the /products page in Spree.  Helps avoid duplicate content issues between home page and /products."
  url "http://github.com/eliotsykes/spree-products-page-remover"

  def activate
    Spree::BaseHelper.class_eval do
      # Avoid using products_path ("/products"), perhaps until the home page 
      # is customized.
      def products_path
        '/'
      end
    end
    
    ProductsController.class_eval do
    
      before_filter :redirect_products_path_to_home, :only => :index
      
      def redirect_products_path_to_home
        # Temporary redirect used in case you want to reintroduce the products
        # page.
        redirect_to '/', :status => 302 if '/products' == request.path
      end
      
    end
    
    TaxonsHelper.class_eval do
      
      # Method copied from existing TaxonsHelper.
      def breadcrumbs(taxon, separator="&nbsp;&raquo;&nbsp;")
        return "" if current_page?("/")
        crumbs = [content_tag(:li, link_to("Home" , root_path) + separator)]
        if taxon
          # Remove the unwanted products link from the breadcrumbs (perhaps 
          # until the home page is cusomtized.
          #crumbs << content_tag(:li, link_to(t('products') , products_path) + separator)
          crumbs << taxon.ancestors.reverse.collect { |ancestor| content_tag(:li, link_to(ancestor.name , seo_url(ancestor)) + separator) } unless taxon.ancestors.empty?
          crumbs << content_tag(:li, content_tag(:span, taxon.name))
        else
          crumbs << content_tag(:li, content_tag(:span, t('products')))
        end
        crumb_list = content_tag(:ul, crumbs)
        content_tag(:div, crumb_list + content_tag(:br, nil, :class => 'clear'), :class => 'breadcrumbs')
      end
      
    end

  end
end
