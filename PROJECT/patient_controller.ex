defmodule Rumbl.PatientController do
  use Rumbl.Web, :controller

  alias Rumbl.Patient

  def index(conn, _params) do
    patients = Repo.all(Patient)
    changeset = Patient.changeset(%Patient{})
    render(conn, "index.html", patients: patients,changeset: changeset)
  end

  def search(conn, params) do
    %{"id" => id} = Map.get(params,"patient")

    changeset = Patient.changeset(%Patient{})
    patients = Repo.all(from p in Patient, where: p.id == ^id , select: p )

    render(conn, "index.html", patients: patients, changeset: changeset)
  end

  def new(conn, _params) do
    changeset = Patient.changeset(%Patient{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"patient" => patient_params}) do
    changeset = Patient.changeset(%Patient{}, patient_params)

    case Repo.insert(changeset) do
      {:ok, patient} ->
        conn
        |> put_flash(:info, "Patient created successfully.")
        |> redirect(to: patient_path(conn, :show, patient))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    patient = Repo.get!(Patient, id)
    render(conn, "show.html", patient: patient)
  end

  def edit(conn, %{"id" => id}) do
    patient = Repo.get!(Patient, id)
    changeset = Patient.changeset(patient)
    render(conn, "edit.html", patient: patient, changeset: changeset)
  end

  def update(conn, %{"id" => id, "patient" => patient_params}) do
    patient = Repo.get!(Patient, id)
    changeset = Patient.changeset(patient, patient_params)

    case Repo.update(changeset) do
      {:ok, patient} ->
        conn
        |> put_flash(:info, "Patient updated successfully.")
        |> redirect(to: patient_path(conn, :show, patient))
      {:error, changeset} ->
        render(conn, "edit.html", patient: patient, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    patient = Repo.get!(Patient, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(patient)

    conn
    |> put_flash(:info, "Patient deleted successfully.")
    |> redirect(to: patient_path(conn, :index))
  end
end
