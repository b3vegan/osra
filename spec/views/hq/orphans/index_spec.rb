require 'rails_helper'
require 'will_paginate/array'

RSpec.describe "hq/orphans/index.html.erb", type: :view do

  describe 'orphans exist' do
    let(:sponsor) { build_stubbed(:sponsor) }
    let(:orphans_count) { build_stubbed_list(:orphan, 5).count }
    let(:orphans_sort_by_eligibility_count) { Orphan.sort_by_eligibility.count }
    let(:eligible_for_sponsorship ) { true }
    let(:orphans) do
      items = build_stubbed_list :orphan, 5
      items.paginate(:page => 2, :per_page => 2)
    end

    before :each do
      assign(:orphans, orphans)
      assign(:filters, {})
    end

    it 'should not indicate no orphans were found' do
      render and expect(rendered).to_not match /No Orphans found/
    end

    it "calls will_paginate gem " do
      allow(view).to receive(:will_paginate).and_return('success')
      render
      expect(rendered).to match /success/
    end

    context 'sponsors exists' do
      before :each do
        assign(:sponsor, sponsor)
      end

      it 'should show all orphans for scope all' do
        assign(:orphans_count, orphans_count)
        render
        expect(rendered).to have_link('All (' + orphans_count.to_s + ')',
                                      hq_new_sponsorship_path(sponsor_id: sponsor.id, scope: :all))
      end

      it 'should show filter orphans for scope eligible for sponsorship' do
        assign(:orphans_sort_by_eligibility_count, orphans_sort_by_eligibility_count)
        assign(:eligible_for_sponsorship, eligible_for_sponsorship)
        render
        expect(rendered).to have_link('Eligible For Sponsorship (' + orphans_sort_by_eligibility_count.to_s + ')',
                                      hq_new_sponsorship_path(sponsor_id: sponsor.id, scope: :eligible_for_sponsorship))
        expect(rendered).to have_content('Beginning')
      end
    end

    context 'sponsors not exists' do
      it 'should show all orphans for scope all' do
        assign(:orphans_count, orphans_count)
        render
        expect(rendered).to have_link('All (' + orphans_count.to_s + ')',
                                      hq_orphans_path(sponsor_id: sponsor.id, scope: :all))
      end

      it 'should show filter orphans for scope eligible for sponsorship' do
        assign(:orphans_sort_by_eligibility_count, orphans_sort_by_eligibility_count)
        render
        expect(rendered).to have_link('Eligible For Sponsorship (' + orphans_sort_by_eligibility_count.to_s + ')',
                                      hq_orphans_path(sponsor_id: sponsor.id, scope: :eligible_for_sponsorship))
      end
    end

    it 'should have filters form' do
      render and expect(response).to render_template(:partial => '_filters.html.erb')
    end

    it "should generate sorted links for table headers" do
      expect(view).to receive(:sortable_link).at_least(:once)

      render
    end
  end

  context 'no orphans exist' do
    before :each do
      assign(:orphans, [])
      assign(:filters, {})
    end

    it 'should indicate no orphans were found' do
      render and expect(rendered).to match /No Orphans found/
    end

    it 'should have filters form' do
      render and expect(response).to render_template(:partial => '_filters.html.erb')
    end
  end
end
