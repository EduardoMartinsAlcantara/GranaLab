import {
    createContext,
    ReactNode,
    useContext,
    useState,
} from 'react';

type RegisterData = {
  name: string;
  email: string;
  password: string;
};

type RegisterContextType = {
  registerData: RegisterData;
  setRegisterData: (data: RegisterData) => void;
  clearRegisterData: () => void;
};

const RegisterContext = createContext<RegisterContextType | undefined>(
  undefined
);

const initialData: RegisterData = {
  name: '',
  email: '',
  password: '',
};

export function RegisterProvider({
  children,
}: {
  children: ReactNode;
}) {
  const [registerData, setRegisterData] =
    useState<RegisterData>(initialData);

  function clearRegisterData() {
    setRegisterData(initialData);
  }

  return (
    <RegisterContext.Provider
      value={{
        registerData,
        setRegisterData,
        clearRegisterData,
      }}
    >
      {children}
    </RegisterContext.Provider>
  );
}

export function useRegister() {
  const context = useContext(RegisterContext);

  if (!context) {
    throw new Error(
      'useRegister deve ser usado dentro de RegisterProvider'
    );
  }

  return context;
}