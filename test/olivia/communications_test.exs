defmodule Olivia.CommunicationsTest do
  use Olivia.DataCase

  alias Olivia.Communications

  describe "subscribers" do
    alias Olivia.Communications.Subscriber

    @valid_attrs %{email: "test@example.com", source: "website_form"}
    @invalid_attrs %{email: nil}

    test "create_subscriber/1 with valid data creates a subscriber" do
      assert {:ok, %Subscriber{} = subscriber} = Communications.create_subscriber(@valid_attrs)
      assert subscriber.email == "test@example.com"
      assert subscriber.source == "website_form"
      assert subscriber.subscribed == true
    end

    test "create_subscriber/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Communications.create_subscriber(@invalid_attrs)
    end

    test "create_subscriber/1 with duplicate email returns error" do
      assert {:ok, _subscriber} = Communications.create_subscriber(@valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Communications.create_subscriber(@valid_attrs)
    end

    test "subscribe/1 is an alias for create_subscriber/1" do
      assert {:ok, %Subscriber{}} = Communications.subscribe(@valid_attrs)
    end

    test "list_subscribers/0 returns all subscribers" do
      {:ok, subscriber} = Communications.create_subscriber(@valid_attrs)
      assert Communications.list_subscribers() == [subscriber]
    end

    test "unsubscribe/1 marks subscriber as unsubscribed" do
      {:ok, subscriber} = Communications.create_subscriber(@valid_attrs)
      assert {:ok, updated} = Communications.unsubscribe(subscriber)
      assert updated.subscribed == false
    end
  end

  describe "enquiries" do
    alias Olivia.Communications.Enquiry

    @valid_attrs %{
      name: "John Doe",
      email: "john@example.com",
      type: "general",
      message: "Hello, I have a question"
    }
    @invalid_attrs %{name: nil, email: nil, type: nil, message: nil}

    test "create_enquiry/1 with valid data creates an enquiry" do
      assert {:ok, %Enquiry{} = enquiry} = Communications.create_enquiry(@valid_attrs)
      assert enquiry.name == "John Doe"
      assert enquiry.email == "john@example.com"
      assert enquiry.type == "general"
      assert enquiry.message == "Hello, I have a question"
    end

    test "create_enquiry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Communications.create_enquiry(@invalid_attrs)
    end

    test "list_enquiries/0 returns all enquiries" do
      {:ok, enquiry} = Communications.create_enquiry(@valid_attrs)
      enquiries = Communications.list_enquiries()
      assert length(enquiries) == 1
      assert hd(enquiries).id == enquiry.id
    end

    test "get_enquiry!/1 returns the enquiry with given id" do
      {:ok, enquiry} = Communications.create_enquiry(@valid_attrs)
      assert Communications.get_enquiry!(enquiry.id).id == enquiry.id
    end

    test "delete_enquiry/1 deletes the enquiry" do
      {:ok, enquiry} = Communications.create_enquiry(@valid_attrs)
      assert {:ok, %Enquiry{}} = Communications.delete_enquiry(enquiry)
      assert_raise Ecto.NoResultsError, fn -> Communications.get_enquiry!(enquiry.id) end
    end
  end

  describe "newsletters" do
    alias Olivia.Communications.Newsletter
    alias Olivia.Accounts

    setup do
      {:ok, user} = Accounts.register_user(%{
        email: "admin@example.com",
        password: "passwordpassword"
      })
      %{user: user}
    end

    @valid_attrs %{
      subject: "Monthly Update",
      body_md: "# Hello\n\nThis is a test newsletter",
      status: "draft"
    }
    @invalid_attrs %{subject: nil, body_md: nil}

    test "create_newsletter/1 with valid data creates a newsletter", %{user: user} do
      attrs = Map.put(@valid_attrs, :user_id, user.id)
      assert {:ok, %Newsletter{} = newsletter} = Communications.create_newsletter(attrs)
      assert newsletter.subject == "Monthly Update"
      assert newsletter.status == "draft"
      assert newsletter.sent_count == 0
    end

    test "create_newsletter/1 with invalid data returns error changeset", %{user: user} do
      attrs = Map.put(@invalid_attrs, :user_id, user.id)
      assert {:error, %Ecto.Changeset{}} = Communications.create_newsletter(attrs)
    end

    test "list_newsletters/0 returns all newsletters", %{user: user} do
      attrs = Map.put(@valid_attrs, :user_id, user.id)
      {:ok, newsletter} = Communications.create_newsletter(attrs)
      newsletters = Communications.list_newsletters()
      assert length(newsletters) == 1
      assert hd(newsletters).id == newsletter.id
    end

    test "update_newsletter/2 with valid data updates the newsletter", %{user: user} do
      attrs = Map.put(@valid_attrs, :user_id, user.id)
      {:ok, newsletter} = Communications.create_newsletter(attrs)
      update_attrs = %{subject: "Updated Subject"}
      assert {:ok, updated} = Communications.update_newsletter(newsletter, update_attrs)
      assert updated.subject == "Updated Subject"
    end

    test "send_newsletter/1 prevents sending already sent newsletters", %{user: user} do
      attrs = Map.put(@valid_attrs, :user_id, user.id)
      {:ok, newsletter} = Communications.create_newsletter(attrs)
      {:ok, sent_newsletter} = Communications.update_newsletter(newsletter, %{status: "sent"})
      assert {:error, :already_sent} = Communications.send_newsletter(sent_newsletter)
    end
  end
end
