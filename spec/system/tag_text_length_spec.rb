require 'rails_helper'

RSpec.describe "タグの文字数制限", type: :system do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "タグ名入力" do
    context "30文字以下のタグ名" do
      let(:valid_tag_name) { "a" * 30 }

      it "タグが正常に作成されること" do
        visit new_tag_path
        fill_in "tag_name", with: valid_tag_name
        click_button "作成"
        expect(page).to have_content("タグを作成しました")
        expect(Tag.last.name).to eq valid_tag_name
      end
    end

    context "30文字を超えるタグ名" do
      let(:invalid_tag_name) { "a" * 31 }

      it "タグは30文字に切り詰められて保存されること" do
        visit new_tag_path
        fill_in "tag_name", with: invalid_tag_name
        click_button "作成"
        # normalize_nameでタグ名は自動的に30文字に切り詰められる
        expect(page).to have_content("タグを作成しました")
        expect(Tag.last.name).to eq invalid_tag_name[0...30]
      end
    end
  end
end