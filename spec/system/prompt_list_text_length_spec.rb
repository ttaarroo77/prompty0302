require 'rails_helper'

RSpec.describe "プロンプト一覧管理画面の文字数制限", type: :system do
  let(:user) { create(:user) }
  let(:prompt) { create(:prompt, user: user) }

  before do
    sign_in user
  end

  describe "タイトル表示" do
    context "50文字以下のタイトル" do
      let(:short_title) { "これは50文字以下のタイトルです" }
      let(:prompt) { create(:prompt, title: short_title, user: user) }

      it "タイトルが完全に表示されること" do
        visit prompts_path
        expect(page).to have_content(short_title)
        expect(page).not_to have_css('.truncate')
      end
    end

    context "50文字を超えるタイトル" do
      let(:long_title) { "これは50文字を超える非常に長いタイトルです。このタイトルは表示時に省略されるはずです。" }
      let(:prompt) { create(:prompt, title: long_title, user: user) }

      it "タイトルが省略表示され、ツールチップが表示されること" do
        visit prompts_path
        expect(page).to have_css('.truncate')
        expect(page).to have_css('[data-tooltip]')
        find('[data-tooltip]').hover
        expect(page).to have_content(long_title)
      end
    end
  end

  describe "説明文表示" do
    context "100文字以下の説明文" do
      let(:short_description) { "これは100文字以下の説明文です。" }
      let(:prompt) { create(:prompt, description: short_description, user: user) }

      it "説明文が完全に表示されること" do
        visit prompts_path
        expect(page).to have_content(short_description)
        expect(page).not_to have_css('.truncate')
      end
    end

    context "100文字を超える説明文" do
      let(:long_description) { "これは100文字を超える非常に長い説明文です。" * 5 }
      let(:prompt) { create(:prompt, description: long_description, user: user) }

      it "説明文が省略表示され、ツールチップが表示されること" do
        visit prompts_path
        expect(page).to have_css('.truncate')
        expect(page).to have_css('[data-tooltip]')
        find('[data-tooltip]').hover
        expect(page).to have_content(long_description)
      end
    end
  end

  describe "タグ表示" do
    context "20文字以下のタグ" do
      let(:short_tag) { create(:tag, name: "短いタグ") }
      let(:prompt) { create(:prompt, tags: [short_tag], user: user) }

      it "タグが完全に表示されること" do
        visit prompts_path
        expect(page).to have_content(short_tag.name)
        expect(page).not_to have_css('.truncate')
      end
    end

    context "20文字を超えるタグ" do
      let(:long_tag) { create(:tag, name: "これは20文字を超える非常に長いタグ名です") }
      let(:prompt) { create(:prompt, tags: [long_tag], user: user) }

      it "タグが省略表示され、ツールチップが表示されること" do
        visit prompts_path
        expect(page).to have_css('.truncate')
        expect(page).to have_css('[data-tooltip]')
        find('[data-tooltip]').hover
        expect(page).to have_content(long_tag.name)
      end
    end

    context "3つ以上のタグ" do
      let(:tags) { create_list(:tag, 4) }
      let(:prompt) { create(:prompt, tags: tags, user: user) }

      it "最初の3つのタグのみが表示され、残りは省略されること" do
        visit prompts_path
        expect(page).to have_content(tags[0].name)
        expect(page).to have_content(tags[1].name)
        expect(page).to have_content(tags[2].name)
        expect(page).not_to have_content(tags[3].name)
        expect(page).to have_content("+1")
      end
    end
  end
end 