class StartPage < SitePrism::Page
  set_url '/'

  element :start_button, '.button-start'
  section :sidebar, '.sidebar' do
    element :heading, 'h2.bold-medium'
    elements :other_services, 'a'
    element :find_a_court, 'a:contains("Find a court or tribunal")[href="https://www.gov.uk/find-court-tribunal"]'
    element :find_a_prison, 'a:contains("Find a prison")[href="https://www.gov.uk/find-prison"]'
    element :visit_a_prison, 'a:contains("Visiting someone in prison")[href="https://www.gov.uk/prison-visits"]'
  end
end
